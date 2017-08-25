# basically higher priority mass scan
class IosEpfScanServiceWorker
  include Sidekiq::Worker
  sidekiq_options retry: false, queue: :ios_mass_lookup

  def perform(ipa_snapshot_job_id, ios_app_id)
    options = {
      scan_worker: IosScanEpfServiceWorker,
      sidekiq_batch_id: bid,
      log_result: true,
      enable_international: false,
      update_job_status: false,
      enable_update_check: true,
      enable_recent_queue_check: true
    }
    IosScanValidationRunner.new(ipa_snapshot_job_id, ios_app_id, options).run
  end
end
