class AppStoreIdsServiceWorker
  include Sidekiq::Worker
  
  def perform(ios_app_snapshot_job_id, ios_app_ids)
    
    ios_app_ids.each do |ios_app_id|
      next unless IosAppSnapshot.where(ios_app_snapshot_job_id: ios_app_snapshot_job_id, ios_app_id: ios_app_id).blank?
      
      
    end
    
  end
  
end