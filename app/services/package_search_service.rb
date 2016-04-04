class PackageSearchService

  class << self

    def classify_jobs(apk_snapshot_job_ids)
      raise "Must be an Array of apk_snapshot_job_ids" unless apk_snapshot_job_ids.is_a?(Array)

      batch = Sidekiq::Batch.new
      size = jobs_apk_snapshots(apk_snapshot_job_ids).count
      notes = "Classify Jobs #{apk_snapshot_job_ids} #{Time.now.strftime("%m/%d/%Y")}"
      batch.description = "Classify ApkSnapshotJobs: ~#{size} ApkSnapshots"
      batch.on(:complete, "PackageSearchService#on_complete_classify_jobs", 'apk_snapshot_job_ids' => apk_snapshot_job_ids, 'apps_queued' => size)
      batch_size = 10e3.to_i
      jobs_apk_snapshots(apk_snapshot_job_ids).find_in_batches(batch_size: batch_size).with_index do |the_batch, index|
        batch.jobs do
          li "App #{index*batch_size}"
          args = the_batch.map{ |x| [x.id] }
          Sidekiq::Client.push_bulk('class' => PackageSearchServiceWorker, 'args' => args)
        end  
      end

      message = "Queued #{size} Android apps for classification."
      Slackiq.message(message, webhook_name: :main)

      true
    end

    private

    def jobs_apk_snapshots(apk_snapshot_job_ids)
      ApkSnapshot.where(apk_snapshot_job_id: apk_snapshot_job_ids)
    end

  end

    def on_complete_classify_jobs(status, options)
      apk_snapshot_job_ids = options['apk_snapshot_job_ids']

      apps_classified = begin
        ApkSnapshot.where(apk_snapshot_job_id: apk_snapshot_job_ids, scan_status: ApkSnapshot.scan_statuses[:scan_success]).count
      rescue => e
        "e.message | e.backtrace"
      end
      
      apps_queued = options['apps_queued']
      Slackiq.notify(webhook_name: :main, status: status, title: "Android App Classification Complete", 'Apps Classified' => apps_classified, 'Apps Queued' => apps_queued, 'apk_snapshot_job_ids' => apk_snapshot_job_ids.to_s)
    end

end