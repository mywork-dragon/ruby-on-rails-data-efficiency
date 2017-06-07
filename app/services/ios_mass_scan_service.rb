class IosMassScanService

  class << self

    def run_ids(notes, ids)

      ipa_snapshot_job = IpaSnapshotJob.create!(job_type: :mass, notes: notes)

      if Rails.env.production?

        Slackiq.message("Starting an iOS download job for #{ids.length} apps", webhook_name: :main)

        batch = Sidekiq::Batch.new
        batch.description = 'iOS Download'
        batch.on(:complete, 'IosMassScanService#on_download_complete', 'job_id' => ipa_snapshot_job.id)

        batch.jobs do
          IosApp.where(id: ids).pluck(:id).each do |ios_app_id|
            IosMassScanServiceWorker.perform_async(ipa_snapshot_job.id, ios_app_id)
          end
        end
      else
        ios_app_id = IosApp.where(id: ids).pluck(:id).sample
        IosMassScanServiceWorker.new.perform(ipa_snapshot_job.id, ios_app_id)
      end
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

    # helper method for running scans
    def run_new(n)
      tried = (IpaSnapshot.select(:ios_app_id).distinct.pluck(:ios_app_id) +
               IpaSnapshotLookupFailure.select(:ios_app_id).distinct.pluck(:ios_app_id)).uniq

      puts "Found all #{tried.count} tried apps"

      mb_high = IosSnapshotAccessor.new.ios_app_ids_from_store_and_priority(1, :high)

      ids = []

      while ids.count < n && mb_high.count > 0 do
        id = mb_high.shift
        ids << id unless tried.include?(id)
      end

      return if ids.count == 0

      puts "Selected #{ids.count} apps in mobile priority high that haven't been tried"

      run_ids("Running #{ids.count} at #{Time.now.strftime '%m/%d/%Y %H:%M %Z'}", ids)
    end

    def run_recently_updated(n: 5000, ratings_min: 0, automated: false)
      recent = IosSnapshotAccessor.new.recently_updated_snapshot_ids(n, ratings_min)

      unless automated
        print "Filtered to recent #{recent.count}. Continue? [y/n] : "
        return unless gets.chomp.include?('y')
      end

      run_ids("Running #{recent.count} recently updated at #{Time.now.strftime '%m/%d/%Y %H:%M %Z'}", recent)
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

    IosMassScanService.scan_successful

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
