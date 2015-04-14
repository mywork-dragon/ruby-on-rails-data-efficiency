class BusinessEntityServiceWorker
  include Sidekiq::Worker

  def perform(ios_app_snapshot_ids)
    
    ios_app_snapshot_ids.each do |ios_app_snapshot_id|
    
      ss = IosAppSnapshot.find(ios_app_snapshot_id)
      
      return if ss.nil?
    
      urls = [ss.seller_url, ss.support_url].select{|url| url}
      
      urls.each do |raw_url|
        url = UrlManipulator.url_with_http_only(raw_url)
        
        w = Website.find_by_url(url)
        
        if w.nil?
          c = Company.find_or_create_by(name: ss.seller)
          w = Website.create(url: url, company: c)
        end
        
        ios_app = ss.ios_app
        
        exsiting_website = Website.where(url: url, ios_app: ios_app)
        
        ios_app.websites << w if existing_website.nil?
        
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