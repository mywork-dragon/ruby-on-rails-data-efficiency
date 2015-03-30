class AppStoreSnapshotService
  
  class << self
  
    def run(notes, options={})
      
      j = IosAppSnapshotJob.create!(notes: notes)
      
      IosAppSnapshot.find_in_batches(batch_size: 100).limit(500) do |ios_app_snapshots|
        puts ios_app_snapshot_ids = ios_app_snapshots.map(&:id)
        # AppStoreSnapshotServiceWorker.perform_async
      end
      
    end
    
    def run_app()
      
    end
  
  end
  
end