class IosMassScanService

  class << self

    def run_ids(notes, ids, use_batch: true)
      ipa_snapshot_job = IpaSnapshotJob.create!(job_type: :mass, notes: notes)
      apps = IosApp.where(id: ids).select(:id, :app_identifier)

      if use_batch
        Slackiq.message("Starting an iOS download job for #{ids.length} apps", webhook_name: :main)

        batch = Sidekiq::Batch.new
        batch.description = 'iOS Download'
        batch.on(:complete, 'IosMassScanService#on_download_complete', 'job_id' => ipa_snapshot_job.id)

        batch.jobs do
          apps.each do |ios_app|
            IosMassScanServiceWorker.perform_async(ipa_snapshot_job.id, ios_app.id)
          end
        end
      else
        apps.each do |ios_app|
          IosMassScanServiceWorker.perform_async(ipa_snapshot_job.id, ios_app.id)
        end
      end

      log_events(apps)
    end

    def log_events(apps)
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
    rescue => e
      Bugsnag.notify(e)
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

    # 36 - "Overall" genre
    def scan_top_epf_rankings(max_rank: 1000, genre_id: 36)
      store_ids = AppStore.where(enabled: true).pluck(:storefront_id)
      date = RedshiftBase.query(
        'select created_at from epf_free_application_popularity_per_genre order by created_at desc limit 1'
      ).fetch.first['created_at']
      app_store_ids = RedshiftBase.query(
        "select distinct(application_id) from epf_free_application_popularity_per_genre " +
        "where convert(integer, storefront_id) in (#{store_ids.join(', ')}) and genre_id = #{genre_id} " +
        "and convert(integer, application_rank) <= #{max_rank} and created_at = '#{date}'"
      ).fetch.map { |x| x['application_id'] }
      app_ids = IosApp.where(app_identifier: app_store_ids).pluck(:id)
      run_ids("Running the EPF top #{max_rank} for rankings on date #{date}", app_ids)
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
