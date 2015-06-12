class JapanAppStoreSnapshotServiceWorker
  include Sidekiq::Worker
  
  # accounting for retries ourself, so disable sidekiq retries
  sidekiq_options retry: false
  
  MAX_TRIES = 3
  
  def perform(job_identifier, ios_app_id)
    
    save_attributes(ios_app_id: ios_app_id, job_identifier: job_identifier)

  end
  
  # I deleted the colons because it was causing an error.
  def save_attributes(ios_app_id, job_identifier)
    ios_app = IosApp.find(ios_app_id)
    
    s = JpIosAppSnapshot.create(ios_app: ios_app, job_identifier: job_identifier)
    
    try = 0
    
    begin
      
      a = AppStoreService.attributes(ios_app.app_identifier, country_code: 'jp', scrape: false)
      
      raise 'AppStoreService.attributes is empty' if a.empty?
    
      single_column_attributes = %w(
        name
        description
        release_notes
        version
        price
        size
        seller
        recommended_age
        required_ios_version
        released
        editors_choice
        developer_app_store_identifier
        icon_url_350x350
        icon_url_175x175
      )
    
      single_column_attributes.each do |sca|
        value = a[sca.to_sym]
        s.send("#{sca}=", value) if value
      end
    
      # Categories
      
      if categories = a[:categories]
        s.category = categories[:primary]
      end
    
      if ratings = a[:ratings]
  
        
        if ratings_current = ratings[:current]
          ratings_current_count = ratings_current[:count].to_i
          s.ratings_current_count = ratings_current_count
          s.ratings_current_stars = ratings_current[:stars]
          
          if released = a[:released]
            days_ago = (Date.tomorrow - released).to_i
            ratings_per_day_current_release = ratings_current_count/(days_ago.to_f)
            s.ratings_per_day_current_release = ratings_per_day_current_release
          end
          
        end
        
      
        if ratings_all = ratings[:all]
          ratings_all_count = ratings_all[:count].to_i #store in memory bc we need it later
          s.ratings_all_count = ratings_all_count
          
          s.ratings_all_stars = ratings_all[:stars]
        end
      end
    
      if seller_url = a[:seller_url]
        s.seller_url = seller_url
      end
    
    
      if support_url = a[:support_url]
         s.support_url = support_url
      end
      
      if icon_urls = a[:icon_urls]
        
        if size_350x350 = icon_urls[:size_350x350]
          s.icon_url_350x350 = size_350x350
        end
        if size_175x175 = icon_urls[:size_175x175]
          s.icon_url_175x175 = size_175x175
        end
      end
      
      japan_scale = 95739/1875709.0 #uses instagram as the baseline
      
      #set user base
      if defined?(ratings_all_count) && defined?(ratings_per_day_current_release)
        if ratings_all_count >= 50e3*japan_scale
          user_base = :elite
        elsif ratings_all_count >= 10e3*japan_scale
          user_base = :strong
        elsif ratings_all_count >= 100*japan_scale
          user_base = :moderate
        else
          user_base = :weak
        end
        
        s.user_base = user_base
      end
      
      
      #set mobile priority
      # if released = a[:released]
      #   if released > 2.months.ago
      #     mobile_priority = :high
      #   elsif released > 4.months.ago
      #     mobile_priority = :medium
      #   else
      #     mobile_priority = :low
      #   end
      #
      #   s.mobile_priority = mobile_priority
      #
      # end
      
    s.save!
    
    rescue => e
      if (try += 1) < MAX_TRIES
        #puts e.message
        retry
      else
        s.status = :failure
        s.save!
      end
    else
      s.status = :success
      s.save!
    end
    
    s
  end
  
end