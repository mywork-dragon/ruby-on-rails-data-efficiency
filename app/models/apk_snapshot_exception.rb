# == Schema Information
#
# Table name: apk_snapshot_exceptions
#
#  id                  :integer          not null, primary key
#  apk_snapshot_id     :integer
#  name                :text(65535)
#  backtrace           :text(65535)
#  try                 :integer
#  apk_snapshot_job_id :integer
#  google_account_id   :integer
#  created_at          :datetime
#  updated_at          :datetime
#  status_code         :integer
#

class ApkSnapshotException < ActiveRecord::Base
  
  belongs_to :apk_snapshot
  belongs_to :apk_snapshot_job
  belongs_to :google_account
  
end
