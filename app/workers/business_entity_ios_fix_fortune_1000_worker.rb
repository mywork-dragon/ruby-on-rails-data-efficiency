class BusinessEntityIosFixFortune1000Worker
  include Sidekiq::Worker
 
  def perform(ios_app_id)
    ios_app = IosApp.find(ios_app_id)
    
    ss = ios_app.newest_ios_app_snapshot
    ss_dasi = ss.developer_app_store_identifier
    
    if company = Company.find_by_app_store_identifier(ss_dasi)
      ios_app.websites << c.websites.first
      ios_app.save
    else
      urls = [ss.seller_url, ss.support_url].select{|url| url}
      
      url.each do |url|
        if UrlHelper.secondary_site?(url)
          kind = :secondary
        else
          url = UrlHelper.url_with_http_and_domain(url)
          kind = :primary
        end
        
        website = Website_find_by_url(url)
        company = website.company
        
        if company.app_store_identifier.blank?
          ios_app.websites << website
          ios_app.save
        end
      end
    end
    
  end
  
end