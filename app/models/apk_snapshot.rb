class ApkSnapshot < ActiveRecord::Base

	belongs_to :google_account
  belongs_to :android_app
  belongs_to :apk_snapshot_jobs

	enum status: [:failure, :success]

end