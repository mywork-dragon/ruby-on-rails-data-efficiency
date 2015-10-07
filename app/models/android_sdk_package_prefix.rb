class AndroidSdkPackagePrefix < ActiveRecord::Base

	belongs_to :android_sdk_company

	has_many :android_sdk_packages

end
