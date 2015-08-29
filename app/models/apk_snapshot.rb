class ApkSnapshot < ActiveRecord::Base

	belongs_to :google_account
  	belongs_to :android_app
  	belongs_to :apk_snapshot_job
  	belongs_to :micro_proxy

  	# will need to get rid of this
  	has_many :android_packages

  	has_many :android_sdk_packages_apk_snapshots
  	has_many :android_sdk_packages, through: :android_sdk_packages_apk_snapshots

	enum status: [:failure, :success, :no_response, :forbidden, :taken_down, :could_not_connect, :timeout, :deadlock]

end