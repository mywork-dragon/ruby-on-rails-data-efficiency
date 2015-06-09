class JapanWhoisServiceWorker
  include Sidekiq::Worker
  
  # accounting for retries ourself, so disable sidekiq retries
  sidekiq_options retry: false
  
  def perform(jp_ios_app_snapshot_id)
    ss = JpIosAppSnapshot.find(jp_ios_app_snapshot_id)
    
    seller_url = ss.seller_url
    
    return if seller_url.blank?
    
    domain = UrlHelper.url_with_domain_only(ss.seller_url)
    
    a = WhoisService.attributes(domain)
    
    ss.business_country_code = a[:country_code]
    ss.business_country = a[:country_full]
    
    ss.save
  end
  
end