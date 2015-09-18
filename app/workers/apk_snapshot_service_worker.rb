class ApkSnapshotServiceWorker

  include Sidekiq::Worker

  sidekiq_options backtrace: true, :retry => 2, queue: :sdk
  
  include ApkWorker

  def retry_possibly(apk_snapshot_job_id, bid, android_app_id)
    # intentional no-op
  end

end