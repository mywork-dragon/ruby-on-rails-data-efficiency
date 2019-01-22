# == Schema Information
#
# Table name: installations
#
#  id                :integer          not null, primary key
#  company_id        :integer
#  service_id        :integer
#  scraped_result_id :integer
#  created_at        :datetime
#  updated_at        :datetime
#  status            :integer
#  scrape_job_id     :integer
#

class Installation < ActiveRecord::Base
  belongs_to :service
  belongs_to :company
  belongs_to :scraped_result
  belongs_to :scrape_job
  # confirmed status means it's matched from our matcher successfully
  # possible status means it's matched the name keyword in the service itself, possibly containing the service, but didn't have a successful matcher
  enum status: [:possible, :confirmed]
end
