class IosReclassificationQueueWorker
  include Sidekiq::Worker
  sidekiq_options backtrace: true, retry: false, queue: :ios_mass_scan_cloud

  def perform
    batch_size = 500
    IpaSnapshot.select(:id).where(
      success: true,
      scan_status: IpaSnapshot.scan_statuses[:scanned]
    ).find_in_batches(batch_size: batch_size)
      .with_index do |the_batch, index|

      args = the_batch.map do |ipa_snapshot|
        [ipa_snapshot.id]
      end

      SidekiqBatchQueueWorker.perform_async(
        IosReclassificationServiceWorker.to_s,
        args,
        bid
      )
    end
  end
end
