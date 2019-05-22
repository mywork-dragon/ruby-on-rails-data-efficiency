# Used in AndroidMassScanServiceWorker

class ApkSnapshotServiceWorker

  include Sidekiq::Worker

  sidekiq_options backtrace: true, retry: false, queue: :android_mass_scan

  RETRIES = 2 # use our own retries

  include ApkWorker

  def classify_if_necessary(apk_ss_id)
    AndroidClassificationServiceWorker.new.perform(apk_ss_id)
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
