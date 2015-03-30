class AppStoreIdsServiceWorker
  include Sidekiq::Worker
  
  def perform(ios_app_snapshot_job_id, ios_app_ids)
    
    ios_app_ids.each do |ios_app_id|
      next unless IosAppSnapshot.where(ios_app_snapshot_job_id: ios_app_snapshot_job_id, ios_app_id: ios_app_id).blank?
      
      ios_app = IosApp.find(ios_app_id)
      a = AppStoreService.attributes(ios_app.app_identifier)
      
      s = IosAppSnapshot.new
      
      s.name = a[:title]
      
      s.description = a[:description]
      
      a[:release_notes]
      
      
      a[:price]
      a[:seller_url]
      a[:categories]
      a[:size]
      a[:seller_url]
      a[:categories]
      a[:size]
      a[:seller]
      a[:developer_app_store_identifier]
      a[:ratings]
      a[:recommended_age]
      a[:required_ios_version]
      a[:support]
      a[:updated]
      a[:languages]
      a[:in_app_purchases]
      a[:editors_choice]
      
      s.save
    end
    
  end
  
end