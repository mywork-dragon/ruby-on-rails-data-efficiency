class ApkSnapshotServiceWorker

  include Sidekiq::Worker

  sidekiq_options backtrace: true, :retry => 2, queue: :sdk_scraper_queue
  
  include ApkWorker

  # Returns true if need to raise exception (always)
  def retry_possibly(apk_snapshot_job_id, bid, android_app_id)
    true
  end

  def single_queue?
    false
  end

end