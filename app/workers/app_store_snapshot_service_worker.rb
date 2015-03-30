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
      developer_app_store_identifier
    )
    
    single_column_attributes.each do |sca|
      value = a[sca.to_sym]
      s.send("#{sca}=", value) if value
    end
    
    # Categories
    if categories = a[:categories]
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
    end
    
    
    
    if ratings = a[:ratings]
      ratings_current = ratings[:current]
      s.ratings_current_count = ratings_current[:count]
      s.ratings_current_stars = ratings_current[:stars]
      
      ratings_all = ratings[:all]
      s.ratings_all_count = ratings_all[:count]
      s.ratings_all_stars = ratings_all[:stars]
    end
    
    if seller_url = a[:seller_url]
      s.seller_url = seller_url
      #TODO: add logic around company
    end
    
    
    if support_url = a[:support_url]
       s.support_url = support_url
       #TODO: add logic around company
    end
   
    
    if languages = a[:languages]
      languages.each do |language_name|
        s.languages << Language.find_or_create_by(name: language_name)
      end
    end
    
    if in_app_purchases = a[:in_app_purchases]
      in_app_purchases.each do |in_app_purchase|
        InAppPurchase.create(title: in_app_purchase[:title], in_app_purchase[:price], ios_app_snapshot: s)
      end
    end
    
    s.save
  end
  
end