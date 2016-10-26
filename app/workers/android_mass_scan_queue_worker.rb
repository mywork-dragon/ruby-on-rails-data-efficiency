class AndroidMassScanQueueWorker
  include Sidekiq::Worker

  sidekiq_options queue: :sdk, retry: false

  def perform(method, *args)
    send(method, *args)
  end

  def queue_worker(apk_snapshot_job_id)
    batch_size = 1_000
    @query.find_in_batches(batch_size: batch_size)
      .with_index do |the_batch, index|

      li "App #{index * batch_size}"

      args = the_batch.map { |android_app| [apk_snapshot_job_id, android_app.id] }

      SidekiqBatchQueueWorker.perform_async(
        AndroidMassScanServiceWorker.to_s,
        args,
        bid
      )
    end
  end

  def queue_updated_by_job_id(current_job_id, previous_job_id = nil, start_job = true)
    date = if previous_job_id
             ApkSnapshotJob.find(previous_job_id).created_at
           else
             1.week.ago
           end
    @query = AndroidApp
      .select(:id)
      .joins(:newest_android_app_snapshot)
      .where('released >= ?', date)
      .where(display_type: AndroidApp.display_types[:normal])

    if start_job
      queue_worker(current_job_id) if start_job
    else
      @query
    end
  end

  def queue_by_ids(apk_snapshot_job_id, ids)
    @query = AndroidApp.where(id: ids)
    queue_worker(apk_snapshot_job_id)
  end
end
