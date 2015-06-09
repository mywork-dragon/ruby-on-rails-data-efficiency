class AppStoreSnapshotService
  
  class << self
  
    def run(notes, options={})
      
      j = IosAppSnapshotJob.create!(notes: notes)
      
      IosApp.find_each.with_index do |ios_app, index|
        li "App ##{index}" if index%10000 == 0
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
        
        JpIosAppSnapshots.where.not(name: nil).find_each do |ss|
          
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
          
          ss << line
        end
      end
      
    end
  
  end
  
end