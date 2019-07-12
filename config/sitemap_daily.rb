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
end