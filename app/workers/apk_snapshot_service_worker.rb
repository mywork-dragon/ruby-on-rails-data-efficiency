class ApkSnapshotServiceWorker

  include Sidekiq::Worker

  sidekiq_options backtrace: true, :retry => 2, queue: :sdk
  
  include ApkWorker

  def retry_possibly(apk_snapshot_job_id, bid, android_app_id)
    break if @retry == 3 # 3 retries max
    retry += 1
    download_apk(apk_snapshot_job_id, bid, android_app_id)
  end

end