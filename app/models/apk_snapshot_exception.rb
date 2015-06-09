class ApkSnapshotException < ActiveRecord::Base
  
  belongs_to :apk_snapshot
  belongs_to :apk_snapshot_job
  belongs_to :google_account
  
end
