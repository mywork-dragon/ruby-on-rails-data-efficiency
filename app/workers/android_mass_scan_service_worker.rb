class AndroidMassScanServiceWorker
  include Android::Scanning::Validator
  include Android::Scanning::ApkWorker
  include Utils::Workers
  include Sidekiq::Worker
  sidekiq_options queue: :android_mass_scan, retry: false

  RETRIES = 2 # use our own retries

  def perform(apk_snapshot_job_id, android_app_id)
    # TODO: Validate exponential backoff here too
    p "Will try to scan: #{android_app_id}"
    start_job if valid_job?(apk_snapshot_job_id, android_app_id)
  end


  private

  def start_job
    @apk_snapshot_job.update!(ls_lookup_code: :initiated) if update_live_scan_job_status?
    if batch.present?
      perform_scan(@apk_snapshot_job.id, bid, @android_app.id)
    else
      perform_scan(@apk_snapshot_job.id, nil, @android_app.id)
    end
  end

  def update_live_scan_job_status?
    false
  end

  def classify_if_necessary(apk_ss_id)
    delegate_perform(AndroidClassificationServiceWorker, apk_ss_id)
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
