class WebsitesDomainDatum < ActiveRecord::Base
  belongs_to :website
  belongs_to :domain_datum
end
