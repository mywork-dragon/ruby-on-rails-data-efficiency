# Used in AndroidLiveScanServiceWorker

class ApkSnapshotServiceSingleWorker

  include Sidekiq::Worker

  sidekiq_options backtrace: true, retry: false, queue: :android_live_scan

  RETRIES = 2

  include ApkWorker

  def initialize
    @retry = 0
  end

  def classify_if_necessary(apk_ss_id)
    AndroidClassificationServiceWorker.new.perform(apk_ss_id)
  end

  def scrape_type
    :live
  end

  def retries
    RETRIES
  end

  def update_live_scan_status_code?
    true
  end

end
