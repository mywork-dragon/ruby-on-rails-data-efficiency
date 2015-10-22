class SdkCompany < ActiveRecord::Base

	has_many :ios_sdks
	has_many :android_sdks

end
