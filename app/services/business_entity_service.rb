class BusinessEntityService

  class << self
  
    def run(ios_app_snapshot_job_ids)
      IosAppSnapshot.where(ios_app_snapshot_job_id: ios_app_snapshot_job_ids).find_in_batches(batch_size: 1000).with_index do |batch, index|
        li "Batch #{index}"
        ios_app_snapshot_ids = batch.map{|ias| ias.id}
        
        BusinessEntityServiceWorker.perform_async(ios_app_snapshot_ids)
      end
    end
  
    
  
  end

end