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
        unchanged: 1,
        not_available: 2,
        paid: 3,
        device_incompatible: 4
        preparing: 5,
        downloading: 6,
        retrying: 7,
        scanning: 8,
        complete: 9,
        failed: 10
      }

      job = IpaSnapshotJob.find(job_id)

      return nil if job.nil? || job.job_type != :one_off 
      
      snapshot = job.ipa_snapshots.first

      # TODO: fix this to update new codes
      status = if job.status != :initiated
        result_map[:validating]
      elsif snapshot.nil?
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