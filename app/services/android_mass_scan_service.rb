class AndroidMassScanService
  # include Sidekiq::Worker
  extend  Utils::Workers
  extend  Android::Scanning::RedshiftStatusLogger

  class << self

    def run_recently_updated(automated: false)
      # App records only come with :id and :app_identifier fields
      apps_to_scan = apps_updated_since(1.week.ago)

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
        # Create 1 SidekiqBatchQueueWorker job for each 1000 apps
        # that in turn will create 1000 AndroidMassScanServiceWorker jobs
        apps_to_scan.each_slice(1000) do |andr_apps|
          args = andr_apps.map { |andr_app| [current_job.id, andr_app.id] }
          delegate_perform(SidekiqBatchQueueWorker, AndroidMassScanServiceWorker.to_s, args, batch.bid)
          # SidekiqBatchQueueWorker.perform_async(
          #   AndroidMassScanServiceWorker.to_s,
          #   args,
          #   batch.bid
          # )
        end
      end

      log_multiple_app_scan_status_to_redshift(apps_to_scan, :attempt, :mass)
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
        android_app_ids.each do |id|
          AndroidMassScanServiceWorker.perform_async(apk_snapshot_job.id, id)
        end
      end
    end

    private

    def apps_updated_since(date)
      AndroidApp
        .select(:id, :app_identifier)
        .joins(:newest_android_app_snapshot)
        .where('released >= ? or android_apps.created_at >= ?', date, date)
        .where(display_type: [AndroidApp.display_types[:normal], AndroidApp.display_types[:foreign]])
    end

  end ## Class methods

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
end
