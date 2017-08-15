class AndroidMassScanService
  class << self

    def apps_updated_since_job(previous_job_id)
      date = if previous_job_id
             ApkSnapshotJob.find(previous_job_id).created_at
           else
             1.week.ago
           end
      query = AndroidApp
        .select(:id)
        .joins(:newest_android_app_snapshot)
        .where('released >= ? or android_apps.created_at >= ?', date, date)
        .where(display_type: AndroidApp.display_types[:normal])

      query
    end

    def queue_apps_for_scan(apk_snapshot_job, batch, apps)
      apps.pluck(:id).each_slice(1000) do |app_ids|
        args = app_ids.map { |app_id| [apk_snapshot_job.id, app_id] }
        SidekiqBatchQueueWorker.perform_async(
          AndroidMassScanServiceWorker.to_s,
          args,
          batch.bid
        )
      end
    end

    def run_recently_updated(automated: false)
      apps_to_scan = apps_updated_since_job(nil)
      unless automated
        count = apps_to_scan.count

        print "Going to scan #{count} apps. Is that ok? [y/n]: "
        ans = gets.chomp
        return unless ans.include?('y')
      end

      current_job = ApkSnapshotJob.create!(
        notes: "Mass Scrape for #{Date.today}",
        job_type: :weekly_mass
      )
      
      batch = Sidekiq::Batch.new
      batch.description = 'Google Play Mass Downloads'
      batch.on(
        :complete,
        'AndroidMassScanService#on_complete',
        'job_id' => current_job.id
      )
      batch.jobs do
        queue_apps_for_scan(current_job, batch, apps_to_scan)
      end
    end

    def run_by_ids(android_app_ids, use_batch: true)
      apk_snapshot_job = ApkSnapshotJob.create!(
        notes: "Mass Scrape by #{android_app_ids.count} ids",
        job_type: :mass
      )


      if use_batch
        batch = Sidekiq::Batch.new
        batch.description = 'Google Play Mass Downloads'
        batch.on(
          :complete,
          'AndroidMassScanService#on_complete',
          'job_id' => apk_snapshot_job.id
        )

        batch.jobs do
          android_app_ids.each do |id|
            AndroidMassScanServiceWorker.perform_async(apk_snapshot_job.id, id)
          end
        end
      else
        AndroidMassScanServiceWorker.perform_async(apk_snapshot_job.id, id)
      end
    end

    def scan_successful
      batch = Sidekiq::Batch.new
      batch.description = 'Google Play Mass Classification'
      batch.on(:complete, 'AndroidMassScanService#on_complete_classify')

      batch.jobs do
        ApkSnapshot.where(
          status: ApkSnapshot.statuses[:success],
          scan_status: nil
        ).pluck(:id).each do |id|
          AndroidClassificationServiceWorker.perform_async(id)
        end
      end
    end
  end

  def on_complete(status, options)
    apk_snapshot_job = ApkSnapshotJob.find(options['job_id'])
    attempted = apk_snapshot_job.apk_snapshot_scrape_failures.count +
      apk_snapshot_job.apk_snapshots
      .select(:android_app_id).distinct
      .count

    successful = apk_snapshot_job
      .apk_snapshots.select(:android_app_id)
      .where(status: ApkSnapshot.statuses[:success])
      .distinct.count

    Slackiq.notify(
      webhook_name: :main,
      status: status,
      title: 'Completed Android downloads for mass scan',
      'Job Description' => apk_snapshot_job.notes,
      'Job Id' => apk_snapshot_job.id,
      '# of Apps Attempted' => attempted,
      'Successes' => successful
    )
  end

  def on_complete_classify(status, options)
    Slackiq.notify(webhook_name: :main, status: status, title: 'Completed Android classification for mass scan')
  end
end
