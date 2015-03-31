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
    
    def test
      100.times{ AppStoreSnapshotServiceWorker.perform_async }
    end
  
  end
  
end