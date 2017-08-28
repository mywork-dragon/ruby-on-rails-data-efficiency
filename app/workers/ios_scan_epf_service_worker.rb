# basically higher priority mass scan
class IosScanEpfServiceWorker
  include Sidekiq::Worker
  sidekiq_options retry: 1, queue: :ios_epf_mass_scan

  def perform(ipa_snapshot_id, bid=nil)
    IosScanRunner.new(ipa_snapshot_id, :mass, {
      start_classify: true,
      classify_worker: IosMassClassificationServiceWorker,
      check_repeated_scan: true,
      scan_type: :mass
    }).run
  end
end
