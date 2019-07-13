require 'rubygems'
require 'sitemap_generator'
# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "https://mightysignal.com"
SitemapGenerator::Sitemap.sitemaps_host = "https://mightysignal-sitemaps.s3.amazonaws.com/"
SitemapGenerator::Sitemap.public_path = 'tmp/'
