class AndroidLiveScanServiceWorker
  include Sidekiq::Worker
  include Android::Scanning::Validator
  extend  Utils::Workers
  extend  Android::Scanning::RedshiftStatusLogger

  RETRIES = 2

  sidekiq_options queue: :live, retry: false


  def self.new_job_for!(android_app_id)
    android_app = AndroidApp.find(android_app_id)

    job = ApkSnapshotJob.create!(
      notes: "SINGLE: #{android_app.app_identifier}",
      job_type: :one_off,
      ls_lookup_code: :preparing
    )

    # Perform Async: To be or not to be, that is the question.
    designate(self, job.id, android_app.id) #Utils::Workers

    job.id
  rescue => e
    p "[Error] #{e.message}"
    log_app_scan_status_to_redshift(android_app, :failed, :live, error: e.message )
  end

  def perform(apk_snapshot_job_id, android_app_id)
    will_perform = valid_job?(apk_snapshot_job_id, android_app_id)
    Rails.logger.debug "Won't perform scanning. Invalid job"
    start_job if will_perform
  end

  def start_job
    @retry = 0
    @apk_snapshot_job.update!(ls_lookup_code: :initiated)
    perform_scan(@apk_snapshot_job.id, nil, @android_app.id)
  end

  private

  def classify_if_necessary(apk_ss_id)
    AndroidClassificationServiceWorker.new.perform(apk_ss_id)
  end

  def update_live_scan_job_status?
    true # allow updates of :ls_lookup_code on apk_snapshot_job
  end

  def update_live_scan_status_code?
    true # allow updates of :ls_download_code on apk_snapshot_job
  end

  def scrape_type
    :live
  end

  def retries
    RETRIES
  end

end
