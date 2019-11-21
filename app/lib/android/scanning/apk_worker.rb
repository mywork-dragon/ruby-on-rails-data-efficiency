module Android
  module Scanning
    module ApkWorker

      attr_reader :apk_snapshot_job, :android_app

      def perform_scan(apk_snapshot_job_id, bid, android_app_id, google_account_id=nil)
        @attempted_google_account_ids = []
        @failed_devices = []
        @apk_snapshot_job ||= ApkSnapshotJob.find(apk_snapshot_job_id)
        @android_app ||= AndroidApp.find(android_app_id)
        download_apk_v2(google_account_id: nil)
      end

      private

      # The path of the apk_file on the box
      def apk_file_path
        apk_file_path = File.join( Rails.root, 'tmp', 'apk_files' )
        FileUtils.mkdir_p(apk_file_path) unless File.directory?(apk_file_path)
        apk_file_path
      end

      def download_apk_v2(google_account_id: nil)
        apk_snapshot_job.update!(ls_download_code: :downloading)

        tries = 0
        success = false
        snapshot = nil
        exception = nil

        while !success && tries <= retries
          begin
            puts "Attempt #{tries}"
            snapshot = download_and_save
            success = true
          rescue MightyApk::MarketApi::NotFound, MightyApk::MarketApi::UnsupportedCountry => e
            p "[Error] #{e.message}"
            exception = e
            break # do not retry in these cases (no-op)
          rescue => e
          p "[Error] Retrying. #{e.message}"
            exception = e
            tries += 1
            apk_snapshot_job.update!(ls_download_code: :retrying) if update_live_scan_status_code?
          end
        end

        snapshot.update!(status: :success) if success
        ls_download_code = success ? :success : :failure
        apk_snapshot_job.update!(ls_download_code: ls_download_code) if update_live_scan_status_code?

        raise exception unless success
      end

      def download_from_play_store(filepath, google_account)
        MightyApk::Market.new(google_account)
          .download!(android_app.app_identifier, filepath)
      rescue MightyApk::MarketApi::NotFound => e
        p "[Error] #{e.merge}"
        # Might not be taken down but incompatible version of phone.
        # android_app.update!(display_type: :taken_down)
        raise e
      rescue MightyApk::MarketApi::UnsupportedCountry => e
        p "[Error] #{e.merge}"
        raise e
      rescue MightyApk::MarketApi::Unauthorized => e
        p "[Error] #{e.merge}"
        google_account.update!(blocked: true)
        notify_blocked_account(google_account)
        raise e
      rescue MightyApk::MarketApi::IncompatibleDevice => e
        p "[Error] #{e.merge}"
        @failed_devices << google_account.device
        raise e
      end

      def notify_blocked_account(google_account)
        message = ":skull_and_crossbones:: Google Account #{google_account.id} has been disabled for authentication issues"
        Slackiq.message(message, webhook_name: :automated_alerts)
        #TODO: MAILER ALERT
      end

      def download_and_save
        snapshot = ApkSnapshot.create!(
          apk_snapshot_job_id: apk_snapshot_job.id,
          android_app_id: android_app.id
        )
        apk_filename = File.join(apk_file_path, "#{snapshot.id}.apk")
        google_account = GoogleAccountReserver.new(snapshot)
                          .reserve(
                            scrape_type,
                            forbidden_google_account_ids: @attempted_google_account_ids,
                            excluded_devices: @failed_devices)
                          .account
        snapshot.update!(google_account_id: google_account.id)
        @attempted_google_account_ids << google_account.id
        region = download_from_play_store(apk_filename, google_account)
        snapshot.set_region(region)
        generate_apk_file(apk_filename, apk_snapshot: snapshot)
        classify_if_necessary(snapshot.id)
        snapshot
      rescue => e
        ApkSnapshotException.create!(
          apk_snapshot_id: snapshot.id,
          apk_snapshot_job_id: apk_snapshot_job_id,
          name: e.message,
          backtrace: e.backtrace
        )
        snapshot.update!(status: :failure)
        raise e
      ensure
        FileUtils.rm_rf(apk_filename) if apk_filename && File.exist?(apk_filename)
        if defined?(google_account_reserver) and not(google_account_reserver.nil?) and google_account_reserver.has_account?
          google_account_reserver.release
        end
      end

      # generate apk file from downloaded apk
      # optionally save the file and its version information directly to apk snapshot
      def generate_apk_file(apk_filename, apk_snapshot: nil)
        apk_file = ApkFile.new
        result = zip_and_save_with_blocks(
          apk_file: apk_file,
          apk_file_path: apk_filename
        )
        version_name = result[:version_name]
        version_code = result[:version_code]

        if apk_snapshot
          apk_snapshot.apk_file = apk_file
          apk_snapshot.version = version_name if version_name.present?
          apk_snapshot.version_code = version_code if version_code.present?
          apk_snapshot.last_updated = DateTime.now
          apk_snapshot.save!
        end
        apk_file
      end

      def classes_from_unzipped_path(unzipped_path)
        dex_files = Dir[File.join(unzipped_path, "*")].map do |file|
          next if not file.ends_with? '.dex'
          file
        end.compact
        classes = []
        dex_files.map do |d|
          begin
            dex_file = File.open(d, "r")
            dex = Android::Dex.new dex_file.read
            dex.classes.map(&:name).each do |c|
              next if c.blank?
              c.sub!(/\AL/, '') # remove leading L
              c = c.split('/')  # split by /
              c = c.join('.').chomp ';'
              classes << c
            end
          ensure
            dex_file.close
          end
        end
        classes
      end

      # unzips, removes multimedia, zips, and saves the apk file to s3
      # returns the apk version information from the manifest
      def zip_and_save_with_blocks(apk_file:, apk_file_path:)
        ret = {}
        Zipper.unzip(apk_file_path) do |unzipped_path|

          versions = ApkVersionGetter.versions(unzipped_path)
          ret.merge!(versions)

          FileRemover.remove_multimedia_files(unzipped_path)

          Zipper.zip(unzipped_path) do |zipped_path|
            apk_file.zip = File.open(zipped_path)
            apk_file.zip_file_name = "#{apk_file_path}.zip"
            apk_file.save!
            apk_file.upload_class_summary(classes_from_unzipped_path(unzipped_path))
          end
        end
        ret
      end
    end
  end
end
