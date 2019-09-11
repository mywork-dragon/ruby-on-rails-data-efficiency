class AndroidMassScanServiceWorker
  include Android::Scanning::Validator
  include Sidekiq::Worker
  sidekiq_options queue: :android_mass_scan, retry: false

  RETRIES = 2 # use our own retries

  def perform(apk_snapshot_job_id, android_app_id)
    start_job if valid_job?(apk_snapshot_job_id, android_app_id)
  end


  private

  def start_job
    if Rails.env.production?
      unless batch.nil?
        batch.jobs do
          ApkSnapshotServiceWorker.perform_async(@apk_snapshot_job.id, bid, @android_app.id)
        end
      else
        ApkSnapshotServiceWorker.perform_async(@apk_snapshot_job.id, nil, @android_app.id)
      end
    else
      ApkSnapshotServiceWorker.new.perform(@apk_snapshot_job.id, nil, @android_app.id)
    end

    @apk_snapshot_job.update!(ls_lookup_code: :initiated) if update_live_scan_job_status?
  end

  def private_perform(apk_snapshot_job_id, bid, android_app_id, google_account_id=nil)
    @attempted_google_account_ids = []
    @failed_devices = []
    download_apk_v2(apk_snapshot_job_id, android_app_id, google_account_id: nil)
  end

  def update_live_scan_job_status?
    false
  end

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
