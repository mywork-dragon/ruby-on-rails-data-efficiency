# == Schema Information
#
# Table name: dll_regexes
#
#  id             :integer          not null, primary key
#  regex          :string(191)
#  android_sdk_id :integer
#  ios_sdk_id     :integer
#  created_at     :datetime
#  updated_at     :datetime
#

class DllRegex < ActiveRecord::Base

  belongs_to :android_sdk
  belongs_to :ios_sdk

  serialize :regex

end
