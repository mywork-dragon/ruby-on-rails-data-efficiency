class SdkRegex < ActiveRecord::Base
  belongs_to :ios_sdk
  belongs_to :android_sdk_company
end
