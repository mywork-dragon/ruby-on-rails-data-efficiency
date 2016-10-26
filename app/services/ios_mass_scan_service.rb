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

    # helper method for running scans
    def run_new(n)
      tried = IosApp.joins(:ipa_snapshots).distinct
      checked = IosApp.joins(:ipa_snapshot_lookup_failures).distinct

      puts "Found all #{tried.count + checked.count} tried apps"

      mb_high_by_ratings = IosApp.joins(:newest_ios_app_snapshot).select(:id).distinct.where.not(id: tried).where.not(id: checked).where(mobile_priority: IosApp.mobile_priorities[:high]).order('ios_app_snapshots.ratings_all_count DESC').limit(n).pluck(:id)

      puts "Selected #{mb_high_by_ratings.length} apps in mobile priority high that haven't been tried"

      run_ids("Running #{n} at #{Time.now.strftime '%m/%d/%Y %H:%M %Z'}", mb_high_by_ratings)
    end

    def run_recently_released(lookback_time: nil, ratings_min: 0, automated: false)

      lookback_time = lookback_time || EpfFullFeed.last(2).first.date
      recent = IosApp.joins(:newest_ios_app_snapshot).where('ios_apps.released >= ?', lookback_time).where('ios_app_snapshots.ratings_all_count > ?', ratings_min).pluck(:id)

      unless automated
        puts "Got #{recent.count} apps: Continue? [y/n]"
        return unless gets.chomp.include?('y')
      end

      run_ids("Running #{recent.count} apps released after #{lookback_time}", recent)
    end

    def run_recently_updated(n: 5000, ratings_min: 0, automated: false)
      recent = IosApp.joins(:newest_ios_app_snapshot)
        .where.not(user_base: IosApp.user_bases[:weak])
        .where(display_type: IosApp.display_types[:normal])
        .where('ios_app_snapshots.released > ?', 2.weeks.ago)
        .where('ios_app_snapshots.ratings_all_count > ?', ratings_min)
        .order('ios_app_snapshots.ratings_all_count DESC')
        .limit(n).pluck(:id)

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
