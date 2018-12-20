# == Schema Information
#
# Table name: header_regexes
#
#  id         :integer          not null, primary key
#  regex      :text(65535)
#  ios_sdk_id :integer
#  created_at :datetime
#  updated_at :datetime
#

class HeaderRegex < ActiveRecord::Base

  belongs_to :ios_sdk

  serialize :regex
end
