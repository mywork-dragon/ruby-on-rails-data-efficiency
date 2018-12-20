# == Schema Information
#
# Table name: scraped_results
#
#  id            :integer          not null, primary key
#  company_id    :integer
#  url           :string(191)
#  raw_html      :text(65535)
#  status        :integer
#  created_at    :datetime
#  updated_at    :datetime
#  scrape_job_id :integer
#

class ScrapedResult < ActiveRecord::Base
  belongs_to :company
  has_many :installations
  belongs_to :scrape_job
  enum status: [ :success, :fail ]
end
