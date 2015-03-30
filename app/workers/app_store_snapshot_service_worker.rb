class AppStoreIdsServiceWorker
  include Sidekiq::Worker
  
  def perform(ios_app_snapshot_job_id, ios_app_ids)
    
    ios_app_ids.each do |ios_app_id|
      next unless IosAppSnapshot.where(ios_app_snapshot_job_id: ios_app_snapshot_job_id, ios_app_id: ios_app_id).blank?
      
      save_attributes(ios_app_id)
    end
    
  end
  
  def save_attributes(ios_app_id)
    ios_app = IosApp.find(ios_app_id)
    a = AppStoreService.attributes(ios_app.app_identifier)
    
    s = IosAppSnapshot.create(ios_app: ios_app)
    
    single_column_attributes = %w(
      name
      description
      release_notes
      price
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
    
    # Categories
    
    categories = a[:categories]
    
    categories_snapshot_primary = IosAppCategoriesSnapshot.new
    categories_snapshot_primary.ios_app_snapshot = s
    categories_snapshot_primary.ios_app_category = IosAppCategory.find_or_create_by(name: categories[:primary])
    categories.type = :primary
    categories_snapshot_primary.save
    
    categories_snapshot_secondary = IosAppCategoriesSnapshot.new
    categories[:secondary].each do |secondary_category|
      categories_snapshot_secondary.ios_app_snapshot = s
      categories_snapshot_secondary.ios_app_category = IosAppCategory.find_or_create_by(name: secondary_category)
      categories.type = :secondary
    end
    categories_snapshot_secondary.save
    
    
    
    
    
    a[:developer_app_store_identifier]
    a[:ratings]
    
    seller_url = a[:seller_url]
    s.seller_url = seller_url
    
    support_url = a[:support_url]
    s.support_url = support_url
    
    a[:languages]
    a[:in_app_purchases]
    
    s.save
  end
  
end