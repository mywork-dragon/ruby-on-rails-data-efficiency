# == Schema Information
#
# Table name: android_sdks_apk_snapshots
#
#  id              :integer          not null, primary key
#  android_sdk_id  :integer
#  apk_snapshot_id :integer
#  created_at      :datetime
#  updated_at      :datetime
#  method          :integer
#

class AndroidSdksApkSnapshot < ActiveRecord::Base
  belongs_to :android_sdk
  belongs_to :apk_snapshot

  enum method: [:packages, :dll_regexes, :js_tag_regexes, :classes]
end
