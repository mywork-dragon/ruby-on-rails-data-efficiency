class BusinessEntityService

  class << self
  
    def run_ios(ios_app_snapshot_job_ids)
      IosAppSnapshot.where(ios_app_snapshot_job_id: ios_app_snapshot_job_ids).find_in_batches(batch_size: 1000).with_index do |batch, index|
        li "Batch #{index}"
        ios_app_snapshot_ids = batch.map{|ias| ias.id}
        
        BusinessEntityServiceIosWorker.perform_async(ios_app_snapshot_ids)
      end
    end
    
    def run_android
    end
  
    
  
  end

end