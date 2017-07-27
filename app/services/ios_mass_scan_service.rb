class IosMassScanService

  class << self

    def run_ids(notes, ids)
      ipa_snapshot_job = IpaSnapshotJob.create!(job_type: :mass, notes: notes)

      Slackiq.message("Starting an iOS download job for #{ids.length} apps", webhook_name: :main)

      batch = Sidekiq::Batch.new
      batch.description = 'iOS Download'
      batch.on(:complete, 'IosMassScanService#on_download_complete', 'job_id' => ipa_snapshot_job.id)

      apps = IosApp.where(id: ids).select(:id, :app_identifier)

      batch.jobs do
        apps.each do |ios_app|
          IosMassScanServiceWorker.perform_async(ipa_snapshot_job.id, ios_app.id)
        end
      end

      logger = RedshiftLogger.new
      apps.map do |app|
        {
          name: 'ios_scan_attempt',
          ios_scan_type: 'mass',
          ios_app_id: app.id,
          ios_app_identifier: app.app_identifier
        }
      end.each { |d| logger.add(d) }
      logger.send!
    end

    def scan_latest_fb_ads(lookback_time: 1.day.ago)
      ids = IosFbAd.select(:ios_app_id).distinct
        .where('date_seen >= ?', lookback_time)
        .pluck(:ios_app_id).compact

      puts "Found #{ids.count} ios apps to scan"

      return if ids.count == 0

      run_ids("Running #{ids.count} apps that have advertised on FB since #{lookback_time}", ids)
    end

    def run_recently_released(lookback_time: nil, ratings_min: 0, automated: false)
      lookback_time = lookback_time || EpfFullFeed.last(2).first.date
      recent = IosSnapshotAccessor.new.recently_released_ios_app_ids(lookback_time, ratings_min, 1)

      unless automated
        puts "Got #{recent.count} apps: Continue [y/n] : "
        return unless gets.chomp.include?('y')
      end

      run_ids("Running #{recent.count} recently updated at #{Time.now.strftime '%m/%d/%Y %H:%M %Z'}", recent)
    end

    def run_recently_updated(limit: nil, ratings_min: 0, since: (DateTime.now() - 7.days).strftime('%Y-%m-%d'))
      recent = IosSnapshotAccessor.new.recently_updated_snapshot_ids(
        limit: limit,
        ratings_min: ratings_min,
        lookback_time: DateTime.strptime(since, '%Y-%m-%d'))

      run_ids("Running #{recent.count} recently updated since #{since}", recent)
    end

    def scan_top_by_rankings(n: 100, kind: :free)
      snapshot = IosAppRankingSnapshot.where(
        kind: IosAppRankingSnapshot.kinds[kind],
        is_valid: true
      ).order(created_at: :desc)
      app_ids = snapshot.ios_app_rankings.limit(n).pluck(:ios_app_id)

      run_ids("Running the top #{n}-ranked #{kind} apps as of #{snapshot.scraped_at} : (#{snapshot.id})", app_ids)
    end

    def scan_successful
      batch = Sidekiq::Batch.new
      batch.description = 'iOS Classification'
      batch.on(:complete, 'IosMassScanService#on_classification_complete')

      batch.jobs do
        IpaSnapshot.where(ipa_snapshot_job: IpaSnapshotJob.where(job_type: 2)).where(success: true).where(scan_status: nil).pluck(:id).each do |id|
          IosMassClassificationServiceWorker.perform_async(id)
        end
      end
    end

  end

  def on_classification_complete(status, options)
    Slackiq.notify(webhook_name: :main, status: status, title: 'Completed iOS classification for mass scan')
  end

  def on_download_complete(status, options)

    ipa_snapshot_job = IpaSnapshotJob.find(options['job_id'])

    Slackiq.notify(webhook_name: :main,
      status: status,
      title: 'Completed iOS downloads for mass scan',
      'Job Id' => ipa_snapshot_job.id,
      '# of Apps Queued' => ipa_snapshot_job.ipa_snapshot_lookup_failures.count + ipa_snapshot_job.ipa_snapshots.count,
      '# of Apps Attempted' => ipa_snapshot_job.ipa_snapshots.count,
      'Successes' => ipa_snapshot_job.ipa_snapshots.where(success: true).count
    )
  end
end
