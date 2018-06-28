class IosLiveScanServiceWorker

  include Sidekiq::Worker

  # retrying the json lookup ourselves, so disable
  sidekiq_options backtrace: true, retry: false, queue: :live

  def perform(ipa_snapshot_job_id, ios_app_id)
    options = {
      scan_worker: IosScanSingleServiceWorker,
      sidekiq_batch_id: bid,
      log_result: true,
      enable_international: true,
      update_job_status: true,
      enable_update_check: true,
      enable_recent_queue_check: false,
      v2_download: true,
      classification_priority: :high
    }
    IosScanValidationRunner.new(ipa_snapshot_job_id, ios_app_id, options).run
  end

end
