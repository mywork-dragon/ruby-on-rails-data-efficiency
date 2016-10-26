class AppStoreSnapshotQueueWorker
  include Sidekiq::Worker

  sidekiq_options queue: :scraper_master, retry: false

  def perform(method, *args)
    send(method, *args)
  end

  def queue_worker
    batch_size = 1_000
    IosApp.select(:id)
      .where(@query)
      .find_in_batches(batch_size: batch_size)
      .with_index do |the_batch, index|
      
      li "App #{index * 1_000}"

      args = the_batch.map { |ios_app| [@ios_app_snapshot_job_id, ios_app.id] }

      SidekiqBatchQueueWorker.perform_async(
        AppStoreSnapshotServiceWorker.to_s,
        args,
        bid
      )
    end
  end

  def queue_valid(ios_app_snapshot_job_id)
    Slackiq.message('Starting to queue App Store apps', webhook_name: :main)
    @ios_app_snapshot_job_id = ios_app_snapshot_job_id
    @query = { display_type: IosApp.display_types.values_at(:paid, :normal, :device_incompatible) }
    queue_worker
    Slackiq.message('Finished queueing App Store apps', webhook_name: :main)
  end

  def queue_new(ios_app_snapshot_job_id)
    Slackiq.message('Queueing new App Store apps', webhook_name: :main)
    @ios_app_snapshot_job_id = ios_app_snapshot_job_id
    previous_week_epf_date = EpfFullFeed.last(2).first.date
    @query = ['released >= ?', previous_week_epf_date]
    queue_worker
    Slackiq.message('Finished queueing new App Store apps', webhook_name: :main)
  end

  def queue_by_ios_app_ids(ios_app_snapshot_job_id, ios_app_ids)
    @ios_app_snapshot_job_id = ios_app_snapshot_job_id
    @query = { id: ios_app_ids }
    queue_worker
  end
end
