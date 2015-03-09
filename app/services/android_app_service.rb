class AndroidAppService
  
  class << self
  
    def attributes(google_play_url)
      

      
      
    end
    
    
    def run(google_play_url)
      
      attrs = GooglePlayService.google_play_attributes(google_play_url)
      
      # seller_url = attributes[:seller_url]
      # funding = CbService.cb_funding(seller_url) if seller_url
      #
      # attributes.merge!({funding: funding})
      
      attrs
      
      app_identifier = attrs[:app_identifier]
      aa = AndroidApp.find_by_app_identifier(app_identifier)
      
      if aa.nil?
        aa = AndroidApp.create(app_identifier: app_identifier)
        li "Created new app with identifier #{app_identifier}"
      end 
      
      version = attrs[:current_version]
      
      aar = AndroidAppRelease.find_by_version(version)
      
      if aar
        ld "AndroidAppRelease #{version} already in DB"
        return
      end
      
      aar = AndroidAppRelease.new(
              name: attrs[:title], 
              category: attrs[:category], 
              price: attrs[:price],
              size: attrs[:size], 
              updated: attrs[:updated], 
              seller_url: attrs[:seller_url], 
              version: version,
              description: attrs[:description], 
              link: google_play_url,
              google_plus_likes: attrs[:google_plus_likes], 
              top_dev: attrs[:top_dev],
              in_app_purchases: attrs[:in_app_purchases], 
              required_android_version: attrs[:required_android_version],
              content_rating: attrs[:content_rating])
              
    aar.android_app = aa
    
    if in_app_cost = attrs[:in_app_cost]
      aiipr = AndroidInAppPurchaseRange.create(min: in_app_cost.min, max: in_app_cost.max)
    end
    
    aar.save
    end
    
  end
end