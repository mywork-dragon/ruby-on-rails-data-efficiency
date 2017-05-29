class IosReclassificationServiceWorker
  include Sidekiq::Worker

  sidekiq_options backtrace: true, retry: false, queue: :ios_reclassification

  def perform(ipa_snapshot_id)
    IosClassificationRunner.new(
      ipa_snapshot_id,
      {
        disable_status_updates: true,
        disable_activity_logging: true,
        classification_options: classification_options
      }
    ).run
  end

  def classification_options
    excludes = IosReclassificationMethod
      .where(active: false)
      .map { |x| x.method.to_sym }
    {
      exclude: excludes
    }
  end
end
