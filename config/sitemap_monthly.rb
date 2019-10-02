require_relative 'sitemap_base'

SitemapGenerator::Sitemap.create do
  group(:sitemaps_path => 'static/', :filename => :static, :changefreq => 'monthly', :priority => 0.5) do
    add data_path
    add publisher_contacts_path
    add web_portal_path
    add the_api_path
    add data_feed_path
    add salesforce_integration_path
    add lead_generation_path
    add abm_path
    add sdk_intelligence_path
    add user_acquisition_path
    add lead_generation_ad_affiliate_networks_path
  end
  
  group(:sitemaps_path => 'ios_sdks/', :filename => :ios_sdks, :changefreq => 'monthly', :priority => 0.8) do
    IosSdk.find_each do |sdk|
      add sdk_page_path('ios', sdk.id, sdk.name.to_s.parameterize)
    end
  end
  
  group(:sitemaps_path => 'android_sdks/', :filename => :android_sdks, :changefreq => 'monthly', :priority => 0.8) do
    AndroidSdk.find_each do |sdk|
      add sdk_page_path('android', sdk.id, sdk.name.to_s.parameterize)
    end
  end
  
  group(:sitemaps_path => 'sdk_categories/', :filename => :sdk_categories, :changefreq => 'monthly', :priority => 0.8) do
    Tag.find_each do |tag|
      add sdk_category_page_path(tag.id, tag.name.to_s.parameterize)
    end
  end
end