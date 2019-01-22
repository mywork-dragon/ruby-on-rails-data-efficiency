# == Schema Information
#
# Table name: ahoy_visits
#
#  id               :integer          not null, primary key
#  visit_token      :string(191)
#  visitor_token    :string(191)
#  user_id          :integer
#  ip               :string(191)
#  user_agent       :text(65535)
#  referrer         :text(65535)
#  referring_domain :string(191)
#  landing_page     :text(65535)
#  browser          :string(191)
#  os               :string(191)
#  device_type      :string(191)
#  country          :string(191)
#  region           :string(191)
#  city             :string(191)
#  utm_source       :string(191)
#  utm_medium       :string(191)
#  utm_term         :string(191)
#  utm_content      :string(191)
#  utm_campaign     :string(191)
#  started_at       :datetime
#

class Ahoy::Visit < ActiveRecord::Base
  self.table_name = "ahoy_visits"

  has_many :events, class_name: "Ahoy::Event"
  belongs_to :lead
end
