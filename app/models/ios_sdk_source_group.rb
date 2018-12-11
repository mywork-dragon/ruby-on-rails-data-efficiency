# == Schema Information
#
# Table name: ios_sdk_source_groups
#
#  id         :integer          not null, primary key
#  name       :string(191)
#  ios_sdk_id :integer
#  flagged    :boolean
#  created_at :datetime
#  updated_at :datetime
#

class IosSdkSourceGroup < ActiveRecord::Base
  has_many :ios_sdks
end
