class BusinessEntityServiceWorker
  include Sidekiq::Worker

  def perform(ios_app_snapshot_ids)
    
    ios_app_snapshot_ids.each do |ios_app_snapshot_id|
    
      ss = IosAppSnapshot.find(ios_app_snapshot_id)
      
      return if ss.nil?
    
      urls = [ss.seller_url, ss.support_url].map{|url| url}
      
      urls.each do |url|
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