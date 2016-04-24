class ApkSnapshotServiceWorker

  include Sidekiq::Worker

  sidekiq_options backtrace: true, retry: false, queue: :sdk
  
  RETRIES = 2 # use our own retries

  MIN_AVAILABLE_ACCOUNTS = 16

  include ApkWorker
  
  MAX_FLAGS = 10

  # Returns true if need to raise exception (always)
  def retry_possibly(apk_snapshot_job_id, bid, android_app_id)
    true
  end

  def choose_google_account(google_account_id: nil, try: 1)
    if google_account_id
      GoogleAccount.find(google_account_id)
    else
      if try == 2
        raise NotEnoughGoogleAccountsAvailable if tablet_query.count < MIN_AVAILABLE_ACCOUNTS
        tablet_query.sample
      else
        raise NotEnoughGoogleAccountsAvailable if phone_query.count < MIN_AVAILABLE_ACCOUNTS
        phone_query.sample
      end
    end
  end

  def tablet_query
    device_names = [:nexus_9_tablet].map(&:to_s)
    devices = GoogleAccount.devices.values_at(*device_names)
    GoogleAccount.where(in_use: false, blocked: false, scrape_type: GoogleAccount.scrape_types[:full], device: devices).where("flags <= ?", MAX_FLAGS)
  end

  def phone_query
    device_names = [:moto_g_phone_1, :moto_g_phone_2, :galaxy_prime_1, :galaxy_prime_2].map(&:to_s)
    devices = GoogleAccount.devices.values_at(*device_names)
    GoogleAccount.where(in_use: false, blocked: false, scrape_type: GoogleAccount.scrape_types[:full], device: devices).where("flags <= ?", MAX_FLAGS)
  end

  def raise_early_stop(apk_snap)
    # NO OP
  end

  def classify_if_necessary(apk_ss_id)
    # NO OP
  end

  def scrape_type
    :full
  end

  def retries
    RETRIES
  end

  class NotEnoughGoogleAccountsAvailable < StandardError
    def initialize(message = "Not enough Google accounts are available.")
      super
    end
  end

end