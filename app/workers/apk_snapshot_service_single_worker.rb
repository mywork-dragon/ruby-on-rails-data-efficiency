class ApkSnapshotServiceSingleWorker

  include Sidekiq::Worker

  sidekiq_options backtrace: true, retry: false, queue: :sdk_live_scan
  # sidekiq_options backtrace: true, retry: false, queue: :sdk   # use this to test on scrapers

  RETRIES = 2

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

  def choose_google_account(google_account_id: nil, try: 1)
    if google_account_id
      GoogleAccount.find(google_account_id)
    else
      if try == 3
        device_names = [:nexus_9_tablet].map(&:to_s)
        devices = GoogleAccount.devices.values_at(*device_names)
        GoogleAccount.where(in_use: false, blocked: false, scrape_type: GoogleAccount.scrape_types[:live], device: devices).sample
      elsif try == 2
        device_names = [:moto_g_phone_1, :moto_g_phone_2].map(&:to_s)
        devices = GoogleAccount.devices.values_at(*device_names)
        GoogleAccount.where(in_use: false, blocked: false, scrape_type: GoogleAccount.scrape_types[:live], device: devices).sample
      else
        device_names = [:galaxy_prime_1, :galaxy_prime_2].map(&:to_s)
        devices = GoogleAccount.devices.values_at(*device_names)
        GoogleAccount.where(in_use: false, blocked: false, scrape_type: GoogleAccount.scrape_types[:live], device: devices).sample
      end
    end
  end

  # Stop the retries early if it looks unrecoverable
  def raise_early_stop(apk_snap)
    # raise ApkWorker::EarlyStop if apk_snap.try > 1 && apk_snap.status.present? && %w(bad_device out_of_country taken_down).any?{|x| apk_snap.status.include? x }
  end

  def classify_if_necessary(apk_ss_id)
    if Rails.env.production?
      PackageSearchServiceSingleWorker.perform_async(apk_ss_id)
    else
      # PackageSearchServiceSingleWorker.new.perform(apk_ss_id)
      puts "Not classifying right now. Done with APK download and upload though."
    end
  end

  def scrape_type
    :live
  end

  def retries
    RETRIES
  end

end