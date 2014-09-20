class Company < ActiveRecord::Base
  has_many :installations
  has_many :scraped_results
  enum status: [ :active, :paused ]
end
