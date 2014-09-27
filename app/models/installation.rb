class Installation < ActiveRecord::Base
  belongs_to :service
  belongs_to :company
  belongs_to :scraped_result
  belongs_to :scrape_job
  # confirmed status means it's matched from our matcher successfully
  # possible status means it's matched the name keyword in the service itself, possibly containing the service, but didn't have a successful matcher
  enum status: [:possible, :confirmed]
end
