# == Schema Information
#
# Table name: apk_snapshots_sdk_js_tags
#
#  id              :integer          not null, primary key
#  apk_snapshot_id :integer
#  sdk_js_tag_id   :integer
#  created_at      :datetime
#  updated_at      :datetime
#

class ApkSnapshotsSdkJsTag < ActiveRecord::Base

  belongs_to :apk_snapshot
  belongs_to :sdk_js_tag

end
