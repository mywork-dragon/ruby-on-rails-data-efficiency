# == Schema Information
#
# Table name: sdk_regexes
#
#  id             :integer          not null, primary key
#  regex          :string(191)
#  ios_sdk_id     :integer
#  android_sdk_id :integer
#  created_at     :datetime
#  updated_at     :datetime
#

class SdkRegex < ActiveRecord::Base
  belongs_to :ios_sdk
  belongs_to :android_sdk_company
end
