class IosMassClassificationServiceWorker
  include Sidekiq::Worker

  sidekiq_options backtrace: true, retry: false, queue: :ios_mass_classification

  def perform(ipa_snapshot_id)
    IosClassificationRunner.new(
      ipa_snapshot_id,
      { log_scan_success: true }
    ).run
  end
end
