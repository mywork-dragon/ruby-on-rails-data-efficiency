class AppStoreSnapshotService
  
  class << self
  
    def run(notes, options={})
      
      j = IosAppSnapshotJob.create!(notes: notes)
      
      IosApp.find_in_batches(batch_size: 100).with_index do |ios_apps, batch|
        li "Batch #{batch}" if batch%100 == 0
        ios_app_ids = ios_apps.map(&:id)
        AppStoreSnapshotServiceWorker.perform_async(j.id, ios_app_ids)
      end
      
    end
    
    def test
      # j = IosAppSnapshotJob.create!(notes: notes)
#
#       ios_app_ids = [389377362, 801207885, 509978909, 946286572, 355074115]
#
#       AppStoreSnapshotServiceWorker.perform_async(j.id, ios_app_ids)

      AppStoreSnapshotServiceWorker
    end
  
  end
  
end