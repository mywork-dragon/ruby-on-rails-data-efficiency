class AppStoreSnapshotService
  
  class << self
  
    def run(notes, options={})
      
      j = IosAppSnapshotJob.create!(notes: notes)
      
      IosApp.find_in_batches(batch_size: 100) do |ios_apps|
        ios_app_ids = ios_apps.map(&:id)
        AppStoreSnapshotServiceWorker.perform_async(j.id, ios_app_ids)
      end
      
    end
    
    def run_app()
      
    end
  
  end
  
end