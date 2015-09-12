class AndroidSdkCompany < ActiveRecord::Base

	has_many :android_sdk_packages
	has_many :android_sdk_package_prefixes

	has_many :android_sdk_companies_apk_snapshots
    has_many :apk_snapshots, through: :android_sdk_companies_apk_snapshots

    has_many :android_sdk_companies_android_apps
    has_many :android_apps, through: :android_sdk_companies_android_apps

end
