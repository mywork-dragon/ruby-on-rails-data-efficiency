# == Schema Information
#
# Table name: android_sdk_packages
#
#  id                            :integer          not null, primary key
#  package_name                  :string(191)
#  android_sdk_package_prefix_id :integer
#  created_at                    :datetime
#  updated_at                    :datetime
#

class AndroidSdkPackage < ActiveRecord::Base

	belongs_to :android_sdk_company
	belongs_to :android_sdk_package_prefix

	has_many :android_sdk_packages_apk_snapshots
  has_many :apk_snapshots, through: :android_sdk_packages_apk_snapshots

end
