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
      tried = (IpaSnapshot.all.pluck(:ios_app_id).uniq + IpaSnapshotLookupFailure.all.pluck(:ios_app_id).uniq).uniq

      puts "Found all #{tried.length} tried apps"

      mb_high_by_ratings = IosApp.joins(:ios_app_snapshots).select(:id).distinct.where.not(id: tried).where(mobile_priority: IosApp.mobile_priorities[:high]).order('ios_app_snapshots.ratings_all_count DESC').limit(n).pluck(:id)

      puts "Selected #{mb_high_by_ratings.length} apps in mobile priority high that haven't been tried"

      run_ids("Running #{n} at #{Time.now.strftime '%m/%d/%Y %H:%M %Z'}", mb_high_by_ratings)
    end

    def run_recently_updated(n: 5000)
      recent = IosApp.joins(:ios_app_snapshots).select(:id).distinct.where('ios_app_snapshots.released > ?', 1.week.ago).order('ios_app_snapshots.ratings_all_count DESC').limit(n).pluck(:id)

      puts "Got #{recent.count} entries"
      # filter out to only those

      # TODO: make this faster
      relevant = recent.select do |ios_app_id|
        ratings = IosAppSnapshot.where(ios_app_id: ios_app_id).last.ratings_all_count
        true if ratings && ratings > 0
      end

      puts "Filtered to relevant #{relevant.count}: Continue? [y/n]"
      return unless gets.chomp.include?('y')

      run_ids("Running #{relevant.count} recently updated at #{Time.now.strftime '%m/%d/%Y %H:%M %Z'}", relevant)
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

    def update_first_valid

      batch = Sidekiq::Batch.new
      batch.description = "update the first valid dates"
      batch.on(:complete, 'IosMassScanService#on_update_complete')

      # already ran it on everything else. Just need the ones afterwards
      IpaSnapshot.select(:id).where('id > 259763').find_in_batches(batch_size: 1000).with_index do |query_batch, index|
        puts "Batch #{index}" if index % 1000
        batch.jobs do
          query_batch.each do |ipa_snapshot|
            FirstValidDateWorker.perform_async(ipa_snapshot.id)
          end
        end
        
      end
    end
    
  end

  def on_update_complete(status, options)
    Slackiq.notify(webhook_name: :main, status: status, title: 'Finished setting correct first valid dates')
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
