# == Schema Information
#
# Table name: apple_accounts
#
#  id            :integer          not null, primary key
#  email         :string(191)
#  password      :string(191)
#  ios_device_id :integer
#  created_at    :datetime
#  updated_at    :datetime
#  app_store_id  :integer
#  kind          :integer
#  in_use        :integer
#  last_used     :datetime
#

class AppleAccount < ActiveRecord::Base
  has_many :ios_devices
  has_many :class_dumps
  belongs_to :app_store
  
  enum kind: [:static, :flex, :v2_download]
end
