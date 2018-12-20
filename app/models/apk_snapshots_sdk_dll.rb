# == Schema Information
#
# Table name: apk_snapshots_sdk_dlls
#
#  id              :integer          not null, primary key
#  apk_snapshot_id :integer
#  sdk_dll_id      :integer
#  created_at      :datetime
#  updated_at      :datetime
#

class ApkSnapshotsSdkDll < ActiveRecord::Base

  belongs_to :apk_snapshot
  belongs_to :sdk_dll

end
