class ScrapeJob < ActiveRecord::Base
  
  has_many :installations
  has_many :scraped_results
  
end
