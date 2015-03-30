class AppStoreSnapshotService
  
  class << self
  
    def run(notes, options={})
      
      j = IosAppSnapshotJob.create!(notes: notes)
      
      IosApps.find_in_batches(batch_size: 100) do |ios_apps|
        sleep 5
        puts ios_app_ids = ios_apps.map(&:id)
        # AppStoreSnapshotServiceWorker.perform_async
      end
      
    end
    
    def run_app()
      
    end
  
  end
  
end