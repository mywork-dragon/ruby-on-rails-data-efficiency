class IosLiveScanService
  class << self
    def scan_ios_app(ios_app_id: ios_app_id)

      app = IosApp.find(ios_app_id)

      return nil if app.nil?

      job = IpaSnapshotJob.create!(job_type: :one_off, live_scan_status: :validating, notes: "running a single live scan job on app #{ios_app_id}")

      if Rails.env.production?
        IosLiveScanServiceWorker.perform_async(job.id, ios_app_id)
      else
        IosLiveScanServiceWorker.new.perform(job.id, ios_app_id)
      end
    end

    def check_status(job_id: job_id)

      result_map = {
        validating: 0,
        preparing: 1,
        downloading: 2,
        retrying: 3,
        scanning: 4,
        complete: 5,
        failed: 6
      }

      job = IpaSnapshotJob.find(job_id)

      return nil if job.nil? || job.job_type != :one_off # might comment out while mocking



      snapshot = job.ipa_snapshots.first

      status = if snapshot.nil?
        result_map[:preparing]
      elsif snapshot.scan_status == :scanned
        result_map[:complete]
      elsif snapshot.scan_status == :scanning
        result_map[:scanning]
      elsif snapshot.download_status == :complete && snapshot.success == false
        result_map[:failed]
      elsif snapshot.download_status == :starting
        result_map[:downloading]
      elsif snapshot.download_status == :retrying
        result_map[:retrying]
      else
        result_map[:failed]
      end

      status
    end
  end
end