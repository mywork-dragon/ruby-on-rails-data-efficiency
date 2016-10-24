class GooglePlaySnapshotQueueWorker
  include Sidekiq::Worker

  sidekiq_options queue: :scraper_master, retry: false

  def perform(method, *args)
    send(method, *args)
  end

  def queue_worker
    batch_size = 1_000
    AndroidApp.select(:id)
      .where(@query)
      .find_in_batches(batch_size: batch_size)
      .with_index do |the_batch, index|
      
      li "App #{index * 1_000}"

      args = the_batch.map { |android_app| [@android_app_snapshot_job_id, android_app.id] }

      SidekiqBatchQueueWorker.perform_async(
        GooglePlaySnapshotMassWorker.to_s,
        args,
        bid
      )
    end
  end

  def queue_valid(android_app_snapshot_job_id)
    Slackiq.message('Queueing Google Play apps', webhook_name: :main)
    @android_app_snapshot_job_id = android_app_snapshot_job_id
    @query = { display_type: AndroidApp.display_types.values_at(:normal) }
    queue_worker
    Slackiq.message('Finished queueing Google Play apps', webhook_name: :main)
  end

  def queue_all(android_app_snapshot_job_id)
    Slackiq.message('Queueing *all* Google Play Apps', webhook_name: :main)
    @android_app_snapshot_job_id = android_app_snapshot_job_id
    @query = nil
    queue_worker
    Slackiq.message('Finished queueing Google Play apps', webhook_name: :main)
  end

  def queue_ids(android_app_snapshot_job_id, android_app_ids)
    Slackiq.message('Queueing specific Google play apps by id', webhook_name: :main)
    @android_app_snapshot_job_id = android_app_snapshot_job_id
    @query = { id: android_app_ids }
    queue_worker
    Slackiq.message('Finished queueing Google Play apps', webhook_name: :main)
  end
end
