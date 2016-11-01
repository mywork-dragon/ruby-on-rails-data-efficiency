class AndroidMassScanService
  class << self
    def run_recently_updated(automated: false)
      previous_job = ApkSnapshotJob.where(
        job_type: ApkSnapshotJob.job_types[:weekly_mass]
      ).last
      previous_job_id = previous_job.id if previous_job

      unless automated
        count = AndroidMassScanQueueWorker.new.queue_updated_by_job_id(
          nil,
          previous_job_id,
          false
        ).count

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
        AndroidMassScanQueueWorker.perform_async(
          :queue_updated_by_job_id,
          current_job.id,
          previous_job_id,
          true
        )
      end
    end

    def run_by_ids(android_app_ids)
      apk_snapshot_job = ApkSnapshotJob.create!(
        notes: "Mass Scrape by #{android_app_ids.count} ids",
        job_type: :mass
      )

      batch = Sidekiq::Batch.new
      batch.description = 'Google Play Mass Downloads'
      batch.on(
        :complete,
        'AndroidMassScanService#on_complete',
        'job_id' => apk_snapshot_job.id
      )

      batch.jobs do
        AndroidApp.where(id: android_app_ids).pluck(:id).each do |id|
          AndroidMassScanServiceWorker.perform_async(apk_snapshot_job.id, id)
        end
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
          AndroidMassClassificationServiceWorker.perform_async(id)
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
