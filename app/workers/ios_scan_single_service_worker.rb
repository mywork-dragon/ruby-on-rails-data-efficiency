class IosScanSingleServiceWorker

  include Sidekiq::Worker

  sidekiq_options retry: false, queue: :ios_live_scan

  def perform(ipa_snapshot_id, bid=nil)
    IosScanRunner.new(ipa_snapshot_id, :one_off, {
      start_classify: true,
      classify_worker: IosClassificationServiceWorker
    }).run
  end

end
