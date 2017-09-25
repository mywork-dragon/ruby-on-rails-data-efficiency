class AndroidLiveScanService
  class UnregisteredCode < RuntimeError; end
  class UnregisteredCondition < RuntimeError; end

  class << self
    def start_scan(android_app_id)
      android_app = AndroidApp.find(android_app_id)
      job = ApkSnapshotJob.create!(
        notes: "SINGLE: #{android_app.app_identifier}",
        job_type: :one_off,
        ls_lookup_code: :preparing
      )
      if Rails.env.production?
        AndroidLiveScanServiceWorker.perform_async(job.id, android_app.id)
      else
        AndroidLiveScanServiceWorker.new.perform(job.id, android_app.id)
      end

      begin
            RedshiftLogger.new(records: [{
              name: 'android_scan_attempt',
              android_scan_type: 'live',
              android_app_id: android_app.id,
              android_app_identifier: android_app.app_identifier
            }]).send!
      rescue => e
        Bugsnag.notify(e)
      end

      job.id
    end

    def status_map
      {
        preparing: 0,
        downloading: 1,
        scanning: 2,
        complete: 3,
        failed: 4, # 500
        unavailable: 5, # 404
        paid: 6, # 402
        unchanged: 7 # 304
      }
    end

    def check_status(job_id:)
      job = ApkSnapshotJob.find(job_id)

      job_status = lookup_code_to_status(job.ls_lookup_code) ||
        download_code_to_status(job.ls_download_code)

      status_sym = if job_status
                     job_status
                   elsif result = find_snapshot_status(job)
                     result
                   else
                     raise UnregisteredCondition
                   end

      status = status_map[status_sym]
      raise UnregisteredCondition, "status: #{status_sym}" unless status
      status
    end

    # returns a status code if has all required information from the status code
    # otherwise, nil
    def lookup_code_to_status(lookup_code)
      case lookup_code.to_sym
      when :preparing, :failed, :unavailable, :paid, :unchanged
        lookup_code.to_sym
      when :initiated
        nil # lookup succeeded but need to look elsewhere for current status
      else
        raise UnregisteredCode, "#{lookup_code}"
      end
    end

    # returns a status code if has all required information from the download code
    # otherwise, nil
    def download_code_to_status(download_code)
      return :preparing if download_code.nil? # download hasn't been started

      case download_code.to_sym
      when :failure
        :failed
      when :downloading, :retrying
        :downloading
      when :success
        nil # download succeeded but need to look elsewhere for scan status
      else
        raise UnregisteredCode, "#{download_code}"
      end
    end

    def find_snapshot_status(job)
      last_snapshot = job.apk_snapshots.last # always use last one
      if last_snapshot.scan_status
        scan_status_to_status(last_snapshot.scan_status.to_sym)
      else
        snapshot_status_to_status(last_snapshot)
      end
    end

    def snapshot_status_to_status(snapshot)
      # for now, error propagation will travel to job level
      # success propagation will be reflected on next call to scan status
      # everything else is still in process --> :downloading
      :downloading
    end

    def scan_status_to_status(scan_status_sym)
      case scan_status_sym
      when :scan_failure
        :failure
      when :scan_success
        :complete
      when :scanning
        :scanning
      end
    end
  end
end
