class IosAppService
  
  class << self
  
    def attributes(app_store_url)
      
      attributes = AppStoreService.app_store_attributes(app_store_url)
      
      downloads_attributes = DownloadsService.downloads_attributes(attributes[:title])
      attributes.merge!(downloads_attributes)
      
      seller_url = attributes[:seller_url]
      funding = CbService.cb_funding(seller_url) if seller_url
      
      attributes.merge!({funding: funding})
      
      
    end
    
  end
end