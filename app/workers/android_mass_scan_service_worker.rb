class AndroidMassScanServiceWorker
  include Sidekiq::Worker
  sidekiq_options queue: :sdk, retry: false

  include AndroidCloud

  def update_live_scan_job_codes?
    false
  end

  def start_job
    if Rails.env.production?
      ApkSnapshotServiceWorker.perform_async(@apk_snapshot_job.id, nil, @android_app.id)
    else
      ApkSnapshotServiceWorker.new.perform(@apk_snapshot_job.id, nil, @android_app.id)
    end

    @apk_snapshot_job.update!(ls_lookup_code: :initiated) if update_live_scan_job_codes?
  end
end
