class IosAppService
  
  class << self
  
    def attributes(app_store_id)
      
      attributes = AppStoreService.attributes(app_store_id)
      
      downloads_attributes = DownloadsService.downloads_attributes(title: attributes[:title], description: attributes[:description])
      attributes.merge!(downloads_attributes)
      
      if cb_url = url_for_cb(attributes)
        # li "cb_url: #{cb_url}"
        seller_domain = UrlManipulator.url_with_domain_only(cb_url)
        funding = CbService.attributes(seller_domain)
      
        attributes.merge!({funding: funding})
      end
      
      attributes
    end
    
    private
    
    def url_for_cb(attributes)
      seller_url = attributes[:seller_url]
      return seller_url if seller_url
      
      support_url = attributes[:support_url]
      
      if seller_url.nil?
        return support_url if support_url
      end
      
      nil
    end
    
  end
end