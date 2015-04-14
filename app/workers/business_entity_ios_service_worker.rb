class BusinessEntityIosServiceWorker
  include Sidekiq::Worker

  def perform(ios_app_snapshot_ids)
    
    ios_app_snapshot_ids.each do |ios_app_snapshot_id|
    
      ss = IosAppSnapshot.find(ios_app_snapshot_id)
      
      return if ss.nil?
    
      urls = [ss.seller_url, ss.support_url].select{|url| url}
      
      urls.each do |url|
        if url_is_social?(url)
          kind = :social
        else
          url = UrlManipulator.url_with_http_and_domain(url)
          kind = :primary
        end
        
        w = Website.find_by_url(url)
        
        if w.nil?
          c = Company.find_by_app_store_identifier(ss.developer_app_store_identifier)
          c = Company.create(name: I18n.transliterate(ss.seller), app_store_identifier: ss.developer_app_store_identifier) if nil?
          w = Website.create(url: url, company: c, kind: kind)
        elsif w.company.nil?
          w.company = Company.create(name: I18n.transliterate(ss.seller), app_store_identifier: ss.developer_app_store_identifier)
          w.save
        end
        
        ios_app = ss.ios_app
        
        ios_app.websites << w if !ios_app.websites.include?(w)
        ios_app.save
        
      end
      
    end
    
  end
  
  def url_is_social?(url)
    social_regexes_strings = %w(
      facebook.com\/.+
      plus.google.com\/+.*
      twitter.com\/.+
      pinterest.com\/.+
      facebook.com\/.+
      instagram.com\/.+
    )
    
    social_regexes = social_regexes_strings.map{|s| Regexp.new(s)}
    
    regex = Regexp.union(social_regexes)
    
    !url.match(regex).nil?
  end
  
end