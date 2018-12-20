# == Schema Information
#
# Table name: android_sdk_package_prefixes
#
#  id                     :integer          not null, primary key
#  prefix                 :string(191)
#  android_sdk_company_id :integer
#

class AndroidSdkPackagePrefix < ActiveRecord::Base

	belongs_to :android_sdk_company

	has_many :android_sdk_packages

end
