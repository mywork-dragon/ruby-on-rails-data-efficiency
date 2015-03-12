class IosAppService
  
  class << self
  
    def attributes(app_store_id)
      
      attributes = AppStoreService.attributes(app_store_id)
      
      downloads_attributes = DownloadsService.downloads_attributes(title: attributes[:title], description: attributes[:description])
      attributes.merge!(downloads_attributes)
      
      seller_url = attributes[:seller_url]
      seller_domain = UrlManipulator.url_with_base_only(seller_url)
      funding = CbService.attributes(seller_domain)
      
      attributes.merge!({funding: funding})
    end
    
    
  end
end