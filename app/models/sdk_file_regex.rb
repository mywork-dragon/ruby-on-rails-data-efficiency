# == Schema Information
#
# Table name: sdk_file_regexes
#
#  id             :integer          not null, primary key
#  regex          :text(65535)
#  android_sdk_id :integer
#  ios_sdk_id     :integer
#  created_at     :datetime
#  updated_at     :datetime
#

class SdkFileRegex < ActiveRecord::Base

  belongs_to :android_sdk
  belongs_to :ios_sdk

  serialize :regex
end
