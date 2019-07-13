require_relative 'sitemap_base'

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