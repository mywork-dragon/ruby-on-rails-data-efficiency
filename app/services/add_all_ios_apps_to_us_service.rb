class AddAllIosAppsToUsService
  
  class << self
    
    def run
      IosApp.find_in_batches(batch_size: 1000).with_index do |batch, index|
        li "Batch #{index}"
        
        ios_app_ids = batch.map{ |ios_app| ios_app.id}
        
        AddAllIosAppsToUsServiceWorker.perform_async(ios_app_ids)
      end
    end
    
  end
  
end