class AppStoreInternationalQueueWorker
  include Sidekiq::Worker
  
  sidekiq_options queue: :scraper_master, retry: false

  def perform(method, *args)
    send(method.to_sym, *args)
  end

  def queue_worker(ios_app_current_snapshot_job_id, worker_class_str, slice_size: 100)
    batch_size = 10e3.to_i
    IosApp.where(display_type: IosApp.display_types[:paid])
      .find_in_batches(batch_size: batch_size)
      .with_index do |the_batch, index|
        li "App #{index*batch_size}"

        args = []

        the_batch.each_slice(slice_size) do |slice|
          slice_app_identifiers = slice.map(&:app_identifier)
          args << [ios_app_current_snapshot_job_id, slice_app_identifiers]
        end        

        # offload batch queueing to worker
        SidekiqBatchQueueWorker.perform_async(
          worker_class_str,
          args,
          bid
        )
    end
  end

  def trigger_scrapes(notes = nil)
    Slackiq.message('Starting to kick off iOS international scrapes via AWS Lambda', webhook_name: :main)

    notes = notes || "Full scrape (international) #{Time.now.strftime("%m/%d/%Y")}"
    j = IosAppCurrentSnapshotJob.create!(notes: notes)

    queue_worker(j.id, AppStoreInternationalTriggerWorker.to_s)
  end

  def load_snapshots(ios_app_current_snapshot_job_id)
    Slackiq.message("Starting to load snapshots from s3 for job id #{ios_app_current_snapshot_job_id}", webhook_name: :main)

    queue_worker(ios_app_current_snapshot_job_id, AppStoreInternationaBulkSnapshotWorker.to_s)
  end
end
