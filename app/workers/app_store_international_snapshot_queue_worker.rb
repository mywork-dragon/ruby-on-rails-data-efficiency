class AppStoreInternationalSnapshotQueueWorker
  include Sidekiq::Worker
  
  sidekiq_options queue: :scraper_master, retry: false

  def perform(scrape_all = false)
    Slackiq.message('Starting to queue iOS international apps', webhook_name: :main)

    notes = "Full scrape (international) #{Time.now.strftime("%m/%d/%Y")}"
    j = IosAppCurrentSnapshotJob.create!(notes: notes)

    batch_size = 1_000

    query = if scrape_all
              "display_type != #{IosApp.display_types[:not_ios]}"
            else
              { app_store_available: true }
            end
    IosApp.where(query)
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
