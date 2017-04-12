class IosClassificationServiceWorker
  include Sidekiq::Worker

  sidekiq_options backtrace: true, retry: false, queue: :ios_live_classification

  def perform(ipa_snapshot_id)
    IosClassificationRunner.new(ipa_snapshot_id).run
  end
end
