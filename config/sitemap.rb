require 'rubygems'
require 'sitemap_generator'
# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "https://mightysignal.com"
SitemapGenerator::Sitemap.sitemaps_host = "https://mightysignal-sitemaps.s3.amazonaws.com/"
SitemapGenerator::Sitemap.public_path = 'tmp/'

SitemapGenerator::Sitemap.adapter = SitemapGenerator::AwsSdkAdapter.new("mightysignal-sitemaps", aws_access_key_id: "#{ENV['S3_ACCESS_KEY_ID']}", aws_secret_access_key: "#{ENV['S3_SECRET_ACCESS_KEY']}", aws_region: 'us-east-1')

SitemapGenerator::Sitemap.create do
  group(:sitemaps_path => 'dynamic/', :filename => :dynamic, :changefreq => 'daily', :priority => 0.9) do
    add root_path
    add top_ios_sdks_path
    add top_ios_apps_path
    add top_android_sdks_path
    add top_android_apps_path
    add fastest_growing_android_sdks_path
    add timeline_path
  end
  
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
  
  group(:sitemaps_path => 'ios_apps/', :filename => :ios_apps, :changefreq => 'weekly', :priority => 0.6) do
    IosApp.find_each do |app|
      add "/a/ios/#{app.app_identifier}/#{app.name.to_s.parameterize}"
    end
  end
  
  group(:sitemaps_path => 'android_apps/', :filename => :android_apps, :changefreq => 'weekly', :priority => 0.6) do
    AndroidApp.find_each do |app|
      add "/a/google-play/#{app.app_identifier}/#{app.name.to_s.parameterize}"
    end
  end
end