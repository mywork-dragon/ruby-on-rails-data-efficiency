class AndroidMassScanServiceWorker
  include Sidekiq::Worker
  sidekiq_options queue: :apk_snapshot_service, retry: false

  include AndroidCloud

  def update_live_scan_job_codes?
    false
  end

  def start_job
    if Rails.env.production?
      unless batch.nil?
        batch.jobs do
          ApkSnapshotServiceWorker.perform_async(@apk_snapshot_job.id, bid, @android_app.id)
        end
      else
        ApkSnapshotServiceWorker.perform_async(@apk_snapshot_job.id, nil, @android_app.id)
      end
    else
      ApkSnapshotServiceWorker.new.perform(@apk_snapshot_job.id, nil, @android_app.id)
    end

    @apk_snapshot_job.update!(ls_lookup_code: :initiated) if update_live_scan_job_codes?
  end
end
