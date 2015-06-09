class GoogleAccount < ActiveRecord::Base

	has_many :apk_snapshots
	has_many :apk_snapshot_exceptions

end
