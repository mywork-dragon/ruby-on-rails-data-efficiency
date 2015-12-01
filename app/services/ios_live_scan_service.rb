class IosLiveScanService
  class << self
    def scan_ios_app(ios_app_id:, job_type: :one_off)

      app = IosApp.find(ios_app_id)

      return nil if app.nil?

      job = IpaSnapshotJob.create!(job_type: job_type, live_scan_status: :validating, notes: "running a single live scan job on app #{ios_app_id} with type #{job_type}")

      if Rails.env.production?
        IosLiveScanServiceWorker.perform_async(job.id, ios_app_id)
      else
        IosLiveScanServiceWorker.new.perform(job.id, ios_app_id)
      end

      job.id
    end

    def check_status(job_id: job_id)

      result_map = {
        validating: 0,
        unchanged: 1,
        not_available: 2,
        paid: 3,
        device_incompatible: 4,
        preparing: 5,
        devices_busy: 6,
        downloading: 7,
        retrying: 8,
        scanning: 9,
        complete: 10,
        failed: 11
      }

      job = IpaSnapshotJob.find(job_id)

      return nil if job.nil? || job.job_type != 'one_off' || job.job_type != 'test'
      
      snapshot = job.ipa_snapshots.first # shouldn't matter...only one snapshot

      # first set of checks: validation stage
      status = if %w(validating not_available paid unchanged device_incompatible failed).include?(job.live_scan_status)
        result_map[job.live_scan_status.to_sym]
      elsif job.live_scan_status != "initiated"
        result_map[:validating]
      end

      return status if !status.nil?

      # second set of checks: download and scan stages
      # Note: the order of these checks matter
      status = if snapshot.nil?
        result_map[:preparing]
      elsif snapshot.scan_status == 'scanned'
        result_map[:complete]
      elsif snapshot.scan_status == 'scanning'
        result_map[:scanning]
      elsif snapshot.scan_status == 'failed'
        result_map[:failed]
      elsif snapshot.download_status == 'complete' && snapshot.success == false
        exception = snapshot.ipa_snapshot_exceptions.last
        exception && exception.error_code == 'devices_busy' ? result_map[:devices_busy] : result_map[:failed]
      elsif snapshot.download_status == 'starting' || snapshot.download_status == 'cleaning'
        result_map[:downloading]
      elsif snapshot.download_status == 'retrying'
        result_map[:retrying]
      else
        result_map[:failed]
      end

      status
    end
  end
end