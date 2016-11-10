module ApkWorker

  def perform(apk_snapshot_job_id, bid, android_app_id, google_account_id=nil)
    @attempted_google_account_ids = []
    @failed_devices = []
    download_apk_v2(apk_snapshot_job_id, android_app_id, google_account_id: nil)
  end
  
  # The path of the apk_file on the box
  def apk_file_path
    if Rails.env.production?
      file_path = '/mnt/apk_files/'
    elsif Rails.env.development?
      file_path = '/tmp'
    end
    file_path
  end

  def download_apk_v2(apk_snapshot_job_id, android_app_id, google_account_id: nil)
    apk_snapshot_job = ApkSnapshotJob.find(apk_snapshot_job_id)
    apk_snapshot_job.update!(ls_download_code: :downloading)

    android_app = AndroidApp.find(android_app_id)
    tries = 0
    success = false
    snapshot = nil

    while !success && tries <= retries
      begin
        puts "Attempt #{tries}"
        snapshot = download_and_save(apk_snapshot_job_id, android_app)
        success = true
      rescue MightyApk::MarketApi::NotFound, MightyApk::MarketApi::UnsupportedCountry
        break # do not retry in these cases (no-op)
      rescue
        tries += 1
        apk_snapshot_job.update!(ls_download_code: :retrying) if update_live_scan_status_code?
      end
    end

    snapshot.update!(status: :success) if success
    ls_download_code = success ? :success : :failure
    apk_snapshot_job.update!(ls_download_code: ls_download_code) if update_live_scan_status_code?
  end

  def download_from_play_store(filepath, android_app, google_account)
    MightyApk::Market.new(google_account).download!(
      android_app.app_identifier,
      filepath
    )
  rescue MightyApk::MarketApi::NotFound => e
    android_app.update!(display_type: :taken_down)
    raise e
  rescue MightyApk::MarketApi::UnsupportedCountry => e
    android_app.update!(display_type: :foreign)
    raise e
  rescue MightyApk::MarketApi::Unauthorized => e
    google_account.update!(blocked: true)
    notify_blocked_account(google_account)
    raise e
  rescue MightyApk::MarketApi::IncompatibleDevice => e
    @failed_devices << google_account.device
    raise e
  end

  def notify_blocked_account(google_account)
    message = ":skull_and_crossbones:: Google Account #{google_account.id} has been disabled for authentication issues"
    Slackiq.message(message, webhook_name: :automated_alerts)
  end
  
  def download_and_save(apk_snapshot_job_id, android_app)
    snapshot = ApkSnapshot.create!(
      apk_snapshot_job_id: apk_snapshot_job_id,
      android_app_id: android_app.id
    )
    apk_filename = File.join(apk_file_path, "#{snapshot.id}.apk")
    google_account_reserver = GoogleAccountReserver.new(snapshot)
    google_account_reserver.reserve(
      scrape_type,
      forbidden_google_account_ids: @attempted_google_account_ids,
      excluded_devices: @failed_devices
    )
    google_account = google_account_reserver.account
    snapshot.update!(google_account_id: google_account.id)
    @attempted_google_account_ids << google_account.id
    download_from_play_store(apk_filename, android_app, google_account)
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
    google_account_reserver.release if google_account_reserver.has_account?
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

  # unzips, removes multimedia, zips, and saves the apk file to s3
  # returns the apk version information from the manifest
  def zip_and_save_with_blocks(apk_file:, apk_file_path:)
    ret = {}
    Zipper.unzip(apk_file_path) do |unzipped_path|

      versions = ApkVersionGetter.versions(unzipped_path)
      ret.merge!(versions)

      FileRemover.remove_multimedia_files(unzipped_path)

      # only s3 upload in production
      Zipper.zip(unzipped_path) do |zipped_path|
        if Rails.env.production?
          apk_file.zip = File.open(zipped_path)
          apk_file.zip_file_name = "#{apk_file_path}.zip"
          apk_file.save!
        end
      end
    end
    ret
  end
end
