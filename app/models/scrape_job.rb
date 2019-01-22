# == Schema Information
#
# Table name: scrape_jobs
#
#  id         :integer          not null, primary key
#  notes      :text(65535)
#  created_at :datetime
#  updated_at :datetime
#

class ScrapeJob < ActiveRecord::Base
  
  has_many :installations
  has_many :scraped_results
  
end
