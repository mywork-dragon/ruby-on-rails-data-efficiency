class AndroidSdkPackage < ActiveRecord::Base

	belongs_to :android_sdk_company
	belongs_to :android_sdk_package_prefix

	has_many :android_sdk_packages_apk_snapshots
    has_many :apk_snapshots, through: :android_sdk_packages_apk_snapshots

end
