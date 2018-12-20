# == Schema Information
#
# Table name: sdk_companies
#
#  id         :integer          not null, primary key
#  name       :string(191)
#  website    :string(191)
#  created_at :datetime
#  updated_at :datetime
#  favicon    :text(65535)
#  flagged    :boolean          default(FALSE)
#

class SdkCompany < ActiveRecord::Base

	has_many :ios_sdks
	has_many :android_sdks

end
