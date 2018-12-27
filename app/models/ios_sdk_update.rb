# == Schema Information
#
# Table name: ios_sdk_updates
#
#  id            :integer          not null, primary key
#  cocoapods_sha :string(191)
#  created_at    :datetime
#  updated_at    :datetime
#

class IosSdkUpdate < ActiveRecord::Base

  has_many :ios_sdk_update_exceptions
end
