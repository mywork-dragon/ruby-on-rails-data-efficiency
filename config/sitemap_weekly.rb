require_relative 'sitemap_base'

SitemapGenerator::Sitemap.adapter = SitemapGenerator::AwsSdkAdapter
                                      .new("mightysignal-sitemaps", 
                                        aws_access_key_id: "#{ENV['S3_ACCESS_KEY_ID']}", 
                                        aws_secret_access_key: "#{ENV['S3_SECRET_ACCESS_KEY']}", 
                                        aws_region: 'us-east-1')

SitemapGenerator::Sitemap.create do
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