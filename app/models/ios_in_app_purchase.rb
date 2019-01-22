# == Schema Information
#
# Table name: ios_in_app_purchases
#
#  id                  :integer          not null, primary key
#  created_at          :datetime
#  updated_at          :datetime
#  name                :string(191)
#  ios_app_snapshot_id :integer
#  price               :integer
#

class IosInAppPurchase < ActiveRecord::Base

  belongs_to :ios_app_snapshot
  
end
