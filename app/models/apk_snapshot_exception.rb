class ApkSnapshotException < ActiveRecord::Base
  
  belongs_to :apk_snapshot_id
  belongs_to :apk_snapshot_job_id
  belongs_to :google_account_id
  
end
