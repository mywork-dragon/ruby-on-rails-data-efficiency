# == Schema Information
#
# Table name: ios_sdk_source_data
#
#  id         :integer          not null, primary key
#  name       :string(191)
#  ios_sdk_id :integer
#  created_at :datetime
#  updated_at :datetime
#  flagged    :boolean          default(FALSE)
#

class IosSdkSourceData < ActiveRecord::Base
  belongs_to :ios_sdk
end
