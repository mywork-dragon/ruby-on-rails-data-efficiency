class ApkSnapshotServiceWorker

  include Sidekiq::Worker

  sidekiq_options backtrace: true, retry: false, queue: :sdk
  
  RETRIES = 2 # use our own retries

  include ApkWorker
  
  def classify_if_necessary(apk_ss_id)
    # NO OP
  end

  def scrape_type
    :full
  end

  def retries
    RETRIES
  end

  def update_live_scan_status_code?
    false
  end

end
