class IosMassScanService

  class << self

    def run_n(notes, n: 10)
    
    ipa_snapshot_job = IpaSnapshotJob.create!(job_type: :mass, notes: notes)

      IosApp.first(n).each do |ios_app|
        IosMassScanServiceWorker.perform_async(ipa_snapshot_job.id, ios_app.id)
      end
      
    end

    def run_ids(notes, ids)

      ipa_snapshot_job = IpaSnapshotJob.create!(job_type: :mass, notes: notes)

      if Rails.env.production?
        IosApp.where(id: ids).find_each do |ios_app|
          IosMassScanServiceWorker.perform_async(ipa_snapshot_job.id, ios_app.id)
        end
      else
        ios_app_id = IosApp.where(id: ids).pluck(:id).sample
        IosMassScanServiceWorker.new.perform(ipa_snapshot_job.id, ios_app_id)
      end
    end

    # helper method for running scans
    def run_nightly(n)
      tried = (IpaSnapshot.all.pluck(:ios_app_id).uniq + IpaSnapshotLookupFailure.all.pluck(:ios_app_id).uniq).uniq

      puts "Found all #{tried.length} tried apps"

      mb_high_by_ratings = IosApp.joins(:ios_app_snapshots).select(:id).distinct.where.not(id: tried).where(mobile_priority: IosApp.mobile_priorities[:high]).order('ios_app_snapshots.ratings_all_count DESC').limit(n).pluck(:id)

      puts "Selected #{mb_high_by_ratings.length} apps in mobile priority high that haven't been tried"

      run_ids("Running #{n} at #{Time.now.strftime '%m/%d/%Y %H:%M %Z'}", mb_high_by_ratings)
    end

    def scan_successful
      batch = Sidekiq::Batch.new
      batch.description = 'iOS Classification'
      batch.on(:complete, 'IosMassScanService#on_classification_complete', test_field: 'sup')

      batch.jobs do
        IpaSnapshot.where(ipa_snapshot_job: IpaSnapshotJob.where(job_type: 2)).where(success: true).where(scan_status: nil).pluck(:id).each do |id|
          IosMassClassificationServiceWorker.perform_async(id)
        end
      end
    end
    
  end

  def on_classification_complete(status, options)
    Slackiq.notify(webhook_name: :main, status: status, title: 'Completed iOS classification for mass scan', test_field: options[:test_field])
  end

end
