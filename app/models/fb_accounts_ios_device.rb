# == Schema Information
#
# Table name: fb_accounts_ios_devices
#
#  id            :integer          not null, primary key
#  fb_account_id :integer
#  ios_device_id :integer
#  flagged       :boolean          default(FALSE)
#  created_at    :datetime
#  updated_at    :datetime
#

class FbAccountsIosDevice < ActiveRecord::Base
  belongs_to :fb_account
  belongs_to :ios_device
end
