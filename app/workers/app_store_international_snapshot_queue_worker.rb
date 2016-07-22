class AppStoreInternationalSnapshotQueueWorker
  include Sidekiq::Worker
  
  sidekiq_options queue: :scraper_master, retry: false

  def perform(notes = nil)
    Slackiq.message('Starting to queue iOS international apps', webhook_name: :main)

    notes = notes || "Full scrape (international) #{Time.now.strftime("%m/%d/%Y")}"
    j = IosAppCurrentSnapshotJob.create!(notes: notes)

    batch_size = 1_000
    IosApp.where(app_store_available: true)
      .find_in_batches(batch_size: batch_size)
      .with_index do |the_batch, index|
        li "App #{index*batch_size}"

        args = []

        # limit at 150 so http requests to iTunes API do not fail
        the_batch.each_slice(150) do |slice|
          slice_ids = slice.map(&:id)
          AppStore.where(enabled: true).each do |app_store|
            args << [j.id, slice_ids, app_store.id]
          end
        end        

        # offload batch queueing to worker
        SidekiqBatchQueueWorker.perform_async(
          AppStoreInternationalSnapshotWorker.to_s,
          args,
          bid
        )
    end

    Slackiq.message("Done queueing App Store apps", webhook_name: :main)
  end
end
