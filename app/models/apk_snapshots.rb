class ApkSnapshots < ActiveRecord::Base

	belongs_to :google_accounts

	enum status: [:failure, :success]

end
