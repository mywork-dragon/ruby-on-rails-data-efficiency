class IosAppService
  
  class << self
  
    def attributes(app_store_url)
      
      app_store_attributes = AppStoreService.app_store_attributes(app_store_url)
      
    end
    
  end
end