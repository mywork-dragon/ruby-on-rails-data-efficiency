class AppStoreSnapshotService
  
  class << self
  
    def run(notes, options={})
      
      j = IosAppSnapshotJob.create!(notes: notes)
      
      # IosApp.find_in_batches(batch_size: 100).with_index do |ios_apps, batch|
      #   li "Batch #{batch}" if batch%100 == 0
      #   ios_app_ids = ios_apps.map(&:id)
      #   AppStoreSnapshotServiceWorker.perform_async(j.id, ios_app_ids)
      # end
      
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
    
    def apps_per_hour(ios_app_snapshot_job_id, sample_seconds=10)
      apps_per_minute(ios_app_snapshot_job_id, sample_seconds)*60.0
    end
    
    def apps_per_day(ios_app_snapshot_job_id, sample_seconds=10)
      apps_per_hour(ios_app_snapshot_job_id, sample_seconds)*24.0
    end
    
    def hours_per_job(ios_app_snapshot_job_id, sample_seconds=10)
      IosApp.count * (1.0 / apps_per_hour(ios_app_snapshot_job_id, sample_seconds))
    end
    
    def test
      100.times{ AppStoreSnapshotServiceWorker.perform_async }
    end
  
  end
  
end