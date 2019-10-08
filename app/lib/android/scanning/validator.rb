module Android
  module Scanning
    module Validator

      # MAX_API_RETRIES_PER_APP = 3

      attr_accessor :apk_snapshot_job,
                    :android_app,
                    :app_attributes

      def valid_job?(apk_snapshot_job_id, android_app_id)
        self.apk_snapshot_job = ApkSnapshotJob.find(apk_snapshot_job_id)
        self.android_app      = AndroidApp.find(android_app_id)
        self.app_attributes   = pull_attributes

        meets_all_conditions?
      rescue => e
        p "[Error] #{e.message}"
        apk_snapshot_job.update!(
          ls_lookup_code: :failed
        ) if update_live_scan_job_status? && apk_snapshot_job

        ApkSnapshotScrapeException.create!(
          apk_snapshot_job_id: apk_snapshot_job_id,
          android_app_id: android_app_id,
          error: e.message,
          backtrace: e.backtrace
        )
        raise e #This mark the job as failed
      end

      def meets_all_conditions?
        unless app_attributes.present?
          Rails.logger.debug 'Couldnt retrieve attributes'
          return false
        end

        if is_paid?
          Rails.logger.debug 'Is paid app'
          handle_paid
          return false
        end

        if nothing_to_update?
          Rails.logger.debug 'Nothing to update'
          handle_unchanged
          return false
        end

        true
      end

      # checks if app is still available in the play store
      def pull_attributes
        # try = 0
        # begin
          GooglePlayDeviceApiService.fetch_app_details_from_api(android_app.app_identifier)
        # rescue GooglePlayDeviceApiService::BadGoogleScrape
        #   Rails.logger.debug '[Error] BadGoogleScrape'
        #   # This is a workaround for a flicker. Sometimes can't find the release date.
        #   if (try += 1) < MAX_API_RETRIES_PER_APP
        #     Rails.logger.debug '[Error] Will retry'
        #     sleep(3.seconds)
        #     retry
        #   else
        #     Rails.logger.debug '[Error] Exhausted retries'
        #     log_result(reason: :bad_google_scrape)
        #     nil
        #   end
        # rescue GooglePlayStore::NotFound
        #   Rails.logger.debug '[Error] NotFound'
        #   handle_not_found
        #   nil
        # rescue GooglePlayStore::Unavailable
        #   Rails.logger.debug '[Error] Unavailable'
        #   handle_unavailable
        #   nil
        # end
      end

      def is_paid?
        attributes[:price] != 0
      end

      def nothing_to_update?
        scrape_version = app_attributes[:version]
        last_scan_version = android_app.newest_apk_snapshot.version if android_app.newest_apk_snapshot_id # latest_snapshot_could_not_exist

        return true if scrape_version.nil? || last_scan_version.nil? || scrape_version.match(/Varies/i)

        scrape_version != last_scan_version
      end

      def handle_unavailable
        log_result(reason: :unavailable)
        android_app.update!(display_type: :taken_down)
        apk_snapshot_job.update!(ls_lookup_code: :unavailable) if update_live_scan_job_status?
      end

      def handle_not_found
        log_result(reason: :not_found)
        android_app.update!(display_type: :taken_down)
        apk_snapshot_job.update!(ls_lookup_code: :unavailable) if update_live_scan_job_status?
      end

      def handle_paid
        log_result(reason: :paid)
        android_app.update!(display_type: :paid)
        apk_snapshot_job.update!(ls_lookup_code: :paid) if update_live_scan_job_status?
      end

      def handle_unchanged
        log_result(reason: :unchanged_version)
        @android_app.newest_apk_snapshot.update!(good_as_of_date: Time.now)
        @apk_snapshot_job.update!(ls_lookup_code: :unchanged) if update_live_scan_job_status?
      end

      def log_result(reason:)
        ApkSnapshotScrapeFailure.create!(
          android_app_id: android_app.id,
          apk_snapshot_job_id: apk_snapshot_job.id,
          reason: reason,
          scrape_content: app_attributes
        )
      end
    end
  end
end
