class ApkSnapshotServiceSingleWorker

  include Sidekiq::Worker

  sidekiq_options backtrace: true, :retry => false, queue: :sdk_single
  
  include ApkWorker

  def initialize(item_name, quantity)
    @retry = 0
  end

  def retry_possibly(apk_snapshot_job_id, bid, android_app_id)
    return if @retry == 3 # 3 retries max
    @retry += 1
    li "Retry #{@retry}"
    download_apk(apk_snapshot_job_id, bid, android_app_id)
  end

end