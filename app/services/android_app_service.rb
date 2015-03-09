class AndroidAppService
  
  class << self
  
    def attributes(google_play_url)
      

      
      
    end
    
    
    def run(google_play_url)
      
      li "hi" 
      return
      
      attrs = GooglePlayService.google_play_attributes(google_play_url)
      
      # seller_url = attributes[:seller_url]
      # funding = CbService.cb_funding(seller_url) if seller_url
      #
      # attributes.merge!({funding: funding})
      
      attrs
      
      app_id = attrs[:app_id]
      app = AndroidApp.find_by_app_id(app_id)
      
      if app.nil?
        app = AndroidApp.create(app_id: app_id)
      end 
      
      version = attrs[:current_version]
      
      aar = AndroidAppRelease.find_by_version(version)
      
      return if aar
      
    end
    
  end
end