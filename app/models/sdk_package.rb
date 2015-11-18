class SdkPackage < ActiveRecord::Base

	belongs_to :ios_sdk
  belongs_to :android_sdk

end
