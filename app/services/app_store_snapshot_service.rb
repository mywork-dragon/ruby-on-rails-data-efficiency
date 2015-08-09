class AppStoreSnapshotService
  
  class << self
  
    def run(notes, options={})
      
      j = IosAppSnapshotJob.create!(notes: notes)
      
      IosApp.find_each.with_index do |ios_app, index|
        li "App ##{index}" if index%10000 == 0
        AppStoreSnapshotServiceWorker.perform_async(j.id, ios_app.id)
      end
      
    end
    
    def run_app_ids(notes, ios_app_ids)
      
      j = IosAppSnapshotJob.create!(notes: notes)
      
      ios_app_ids.each do |ios_app_id|
        AppStoreSnapshotServiceWorker.perform_async(j.id, ios_app_id)
      end
      
    end
    
    def run_random(notes, n=1000)
      
      j = IosAppSnapshotJob.create!(notes: notes)
      
      n.times do
        offset = rand(IosApp.count)
        ios_app = IosApp.offset(offset).first
        
        next if ios_app.nil?
        
        AppStoreSnapshotServiceWorker.perform_async(j.id, ios_app.id)
      end

      
    end
    
    def apps_per_minute(ios_app_snapshot_job_id, sample_seconds=10)
      a = IosAppSnapshot.where(ios_app_snapshot_job_id: ios_app_snapshot_job_id).count
      sleep sample_seconds
      b = IosAppSnapshot.where(ios_app_snapshot_job_id: ios_app_snapshot_job_id).count 
      60.0/sample_seconds*(b-a)
    end
    
    def apps_per_hour(ios_app_snapshot_job_id=IosAppSnapshotJob.last.id, sample_seconds=10)
      apps_per_minute(ios_app_snapshot_job_id, sample_seconds)*60.0
    end
    
    def apps_per_day(ios_app_snapshot_job_id=IosAppSnapshotJob.last.id, sample_seconds=10)
      apps_per_hour(ios_app_snapshot_job_id, sample_seconds)*24.0
    end
    
    def hours_per_job(ios_app_snapshot_job_id=IosAppSnapshotJob.last.id, sample_seconds=10)
      IosApp.count * (1.0 / apps_per_hour(ios_app_snapshot_job_id, sample_seconds))
    end
    
    def test
      100.times{ AppStoreSnapshotServiceWorker.perform_async }
    end
    
    def run_japan(job_identifier)
      app_store = AppStore.find_by_country_code('jp')
      
      AppStoresIosApp.where(app_store: app_store).find_each.with_index do |app_stores_ios_app, index|
        li "App ##{index}" if index%10000 == 0
        
        ios_app = app_stores_ios_app.ios_app
        
        JapanAppStoreSnapshotServiceWorker.perform_async(job_identifier, ios_app.id)
      end
    end
    
    def japan_csv(file_path)
      
      CSV.open(file_path, "w+") do |csv|
        csv << ['Name', 'Description', 'Release Notes', 'Category', 'Size (B)', 'Seller URL', 'Support URL', 'Version', 'Current Rating Average', 'Number of Current Ratings', 'All Time Ratings Stars', 'All Time Ratings Count', 'User Base']
        
        JpIosAppSnapshot.where.not(name: nil).order('user_base ASC').find_each do |ss|
          
          line = []
          
          line << ss.name
          line << ss.description
          line << ss.release_notes
          line << ss.category
          line << ss.size
          line << ss.seller_url
          line << ss.support_url
          line << ss.version
          line << ss.ratings_current_stars
          line << ss.ratings_current_count
          line << ss.ratings_all_stars
          line << ss.ratings_all_count
          line << ss.user_base.capitalize
          
          csv << line
        end
      end
      
    end
    
    # Last week
    def run_new_apps(notes)
      j = IosAppSnapshotJob.create!(notes: notes)
      
      batch = Sidekiq::Batch.new
      batch.description = "run_new_apps: #{notes}" 
      batch.on(:complete, 'AppStoreSnapshotService#on_complete_run_new_apps')
  
      batch.jobs do
        epf_full_feed_last = EpfFullFeed.last
    
        newest_date = IosAppEpfSnapshot.order('itunes_release_date DESC').limit(1).first.itunes_release_date
        week_before_newest = newest_date - 6.days


        IosAppEpfSnapshot.where(epf_full_feed: epf_full_feed_last, itunes_release_date:  week_before_newest..newest_date).find_each.with_index do |epf_ss, index| 
          
          app_identifer = epf_ss.application_id
          
          ios_app = IosApp.find_by_app_identifier(app_identifer)
          
          if ios_app
            AppStoreSnapshotServiceWorker.perform_async(j.id, ios_app.id)
          end
        
        end
    
      end
      
    end
  
  end
  
  def on_complete_run_new_apps(status, options)
    Slackiq.notify(webhook_name: :main, status: status, title: 'Run New Apps Completed')
  end
  
  
end