class ApkSnapshotServiceWorker

  include Sidekiq::Worker

  sidekiq_options backtrace: true, retry: false, queue: :sdk
  
  RETRIES = 2 # use our own retries

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
        GoogleAccount.where(in_use: false, blocked: false, scrape_type: :full, device: :nexus_9_tablet).where("flags <= ?", MAX_FLAGS).sample
      else
        GoogleAccount.where(in_use: false, blocked: false, scrape_type: :full, device: [:moto_g_phone_1, :moto_g_phone_2]).where("flags <= ?", MAX_FLAGS).sample
      end
    end
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

end