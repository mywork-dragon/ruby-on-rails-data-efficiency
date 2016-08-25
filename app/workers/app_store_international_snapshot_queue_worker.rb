class AppStoreInternationalSnapshotQueueWorker
  include Sidekiq::Worker
  
  sidekiq_options queue: :scraper_master, retry: false

  class UnrecognizedType < RuntimeError; end

  def perform(scrape_type)
    @scrape_type = scrape_type.to_sym
    Slackiq.message('Starting to queue iOS international apps', webhook_name: :main)

    notes = "Full scrape (international) #{Time.now.strftime("%m/%d/%Y")}"
    j = IosAppCurrentSnapshotJob.create!(notes: notes)

    batch_size = 1_000

    query = ios_app_query_by_scrape_type
    snapshot_worker = snapshot_worker_by_scrape_type

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
          snapshot_worker.to_s,
          args,
          bid
        )
    end

    Slackiq.message("Done queueing App Store apps", webhook_name: :main)
  end

  def ios_app_query_by_scrape_type
    if @scrape_type == :all
      "display_type != #{IosApp.display_types[:not_ios]}"
    elsif @scrape_type == :regular
      { app_store_available: true }
    elsif @scrape_type == :new
      previous_week_epf_date = Date.parse(EpfFullFeed.last(2).first.name)
      ['released >= ?', previous_week_epf_date]
    else
      raise UnrecognizedType
    end
  end

  def snapshot_worker_by_scrape_type
    if @scrape_type == :new
      AppStoreInternationalCurrentSnapshotWorker
    else
      AppStoreInternationalSnapshotWorker
    end
  end

end
