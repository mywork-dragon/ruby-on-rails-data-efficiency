class IosAppService
  
  class << self
  
    def attributes(app_store_url)
      
      attributes = AppStoreService.app_store_attributes(app_store_url)
      
      downloads_attributes = DownloadsService.downloads_attributes(attributes[:title])
      attributes.merge!(downloads_attributes)
      
      
    end
    
  end
end