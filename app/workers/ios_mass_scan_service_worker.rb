class IosMassScanServiceWorker
  include Sidekiq::Worker

  sidekiq_options backtrace: true, retry: false, queue: :ios_mass_lookup

  def perform(ipa_snapshot_job_id, ios_app_id)
    options = {
      scan_worker: IosScanMassServiceWorker,
      sidekiq_batch_id: bid,
      log_result: true,
      enable_international: false,
      update_job_status: false,
      enable_update_check: true,
      enable_recent_queue_check: true,
      v2_download: true,
      classification_priority: :mass
    }
    IosScanValidationRunner.new(ipa_snapshot_job_id, ios_app_id, options).run
  end
end
