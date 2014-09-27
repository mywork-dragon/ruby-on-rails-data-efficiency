class ScrapedResult < ActiveRecord::Base
  belongs_to :company
  has_many :installations
  belongs_to :scrape_job
  enum status: [ :success, :fail ]
end
