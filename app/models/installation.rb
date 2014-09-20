class Installation < ActiveRecord::Base
  belongs_to :service
  belongs_to :company
  belongs_to :scraped_result
end
