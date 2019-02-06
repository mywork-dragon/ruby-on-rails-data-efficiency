# == Schema Information
#
# Table name: sdk_string_regexes
#
#  id          :integer          not null, primary key
#  regex       :text(65535)
#  min_matches :integer          default(0)
#  ios_sdk_id  :integer
#  created_at  :datetime
#  updated_at  :datetime
#

class SdkStringRegex < ActiveRecord::Base

  belongs_to :ios_sdk

  serialize :regex
end
