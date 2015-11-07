class ApkSnapshotServiceSingleWorker

  include Sidekiq::Worker

  sidekiq_options backtrace: true, :retry => 2, queue: :sdk
  
  include ApkWorker

  def initialize
    @retry = 0
  end

  # Returns true if need to raise exception (hit the last retry)
  def retry_possibly(apk_snapshot_job_id, bid, android_app_id)
    return true if @retry == 3 # 3 retries max
    @retry += 1
    li "Retry #{@retry}"
    download_apk(apk_snapshot_job_id, bid, android_app_id)
    false
  end

  def single_queue?
    true
  end

end