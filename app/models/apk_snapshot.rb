class ApkSnapshot < ActiveRecord::Base

	belongs_to :google_account
  	belongs_to :android_app
  	belongs_to :apk_snapshot_job
  	belongs_to :micro_proxy

  	has_many :android_sdk_packages_apk_snapshots
  	has_many :android_sdk_packages, through: :android_sdk_packages_apk_snapshots

  	has_many :android_sdk_companies_apk_snapshots
	has_many :android_sdk_companies, through: :android_sdk_companies_apk_snapshots

  	belongs_to :apk_file

	enum status: [:failure, :success, :no_response, :forbidden, :taken_down, :could_not_connect, :timeout, :deadlock]

end