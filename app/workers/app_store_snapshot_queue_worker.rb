class AppStoreSnapshotQueueWorker
  include Sidekiq::Worker

  sidekiq_options queue: :scraper_master, retry: false

  # TODO: on each method, store the proper query in an instance variable
  # then in the queue_worker method below, use it
  def queue_worker

    batch_size = 1_000
    IosApp.select(:id)
      .where(@query)
      .find_in_batches(batch_size: batch_size)
      .with_index do |the_batch, index|

      args = the_batch.map { |ios_app| [@ios_app_snapshot_job_id, ios_app.id] }

      # SidekiqBatchQueueWorker.perform_async(
      #   AppStoreSnapshotServiceWorker.to_s,
      #   args,
      #   bid
      # )
    end
  end

  def queue_valid(ios_app_snapshot_job_id)
    @ios_app_snapshot_job_id = ios_app_snapshot_job_id
    queue_worker(display_type: IosApp.display_types.values_at(:paid, :normal, :device_incompatible))
  end

  def queue_new(ios_app_snapshot_job_id)
    @ios_app_snapshot_job_id = ios_app_snapshot_job_id
    previous_week_epf_date = Date.parse(EpfFullFeed.last(2).first.name)
    queue_
  end
end
