class IosScanMassServiceWorker

  include Sidekiq::Worker

  sidekiq_options retry: 1, queue: :ios_mass_scan

  def perform(ipa_snapshot_id, bid=nil)
    IosScanRunner.new(ipa_snapshot_id, :mass).run
  end
end
