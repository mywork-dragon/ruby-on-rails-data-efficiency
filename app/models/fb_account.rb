# == Schema Information
#
# Table name: fb_accounts
#
#  id           :integer          not null, primary key
#  username     :string(191)
#  password     :string(191)
#  last_browsed :datetime
#  last_scraped :datetime
#  flagged      :boolean          default(FALSE)
#  created_at   :datetime
#  updated_at   :datetime
#  browsable    :boolean          default(FALSE)
#  purpose      :integer
#  in_use       :boolean          default(FALSE)
#

class FbAccount < ActiveRecord::Base
  has_many :fb_activities
  has_many :ios_fb_ads
  has_many :ios_fb_ad_exceptions

  has_many :fb_accounts_ios_devices
  has_many :ios_devices, -> { where 'fb_accounts_ios_devices.flagged' => false }, through: :fb_accounts_ios_devices

  enum purpose: [:ios_ad_spend, :mau_scrape]
end
