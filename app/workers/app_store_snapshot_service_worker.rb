class AppStoreIdsServiceWorker
  include Sidekiq::Worker
  
  def perform(ios_app_snapshot_job_id, ios_app_ids)
    
    ios_app_ids.each do |ios_app_id|
      next unless IosAppSnapshot.where(ios_app_snapshot_job_id: ios_app_snapshot_job_id, ios_app_id: ios_app_id).blank?
      
      ios_app = IosApp.find(ios_app_id)
      a = AppStoreService.attributes(ios_app.app_identifier)
      
      s = IosAppSnapshot.new
      
      single_column_attributes = %w(
        name
        description
        release_notes
        price
        seller_url
        size
        seller
        recommended_age
        required_ios_version
        released
        editors_choice
      )
      
      single_column_attributes.each do |sca|
        s.send("#{sca}=", a[sca.to_sym])
      end
      
      
      a[:categories]
      a[:developer_app_store_identifier]
      a[:ratings]
      
      support_url = a[:support_url]
      s.support_url = support_url
      
      a[:languages]
      a[:in_app_purchases]
      
      s.save
    end
    
  end
  
end