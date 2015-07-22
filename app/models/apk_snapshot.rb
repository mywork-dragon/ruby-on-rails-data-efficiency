class ApkSnapshot < ActiveRecord::Base

	belongs_to :google_account
	belongs_to :super_proxy
  	belongs_to :android_app
  	belongs_to :apk_snapshot_jobs
  
  	has_many :android_packages

	enum status: [:failure, :success, :no_response]

end