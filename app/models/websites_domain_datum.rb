# == Schema Information
#
# Table name: websites_domain_data
#
#  id              :integer          not null, primary key
#  website_id      :integer
#  domain_datum_id :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class WebsitesDomainDatum < ActiveRecord::Base
  belongs_to :website
  belongs_to :domain_datum
end
