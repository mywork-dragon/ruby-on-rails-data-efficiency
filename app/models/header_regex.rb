class HeaderRegex < ActiveRecord::Base

  belongs_to :ios_sdk

  serialize :regex
end
