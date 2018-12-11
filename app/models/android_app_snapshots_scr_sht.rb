# == Schema Information
#
# Table name: android_app_snapshots_scr_shts
#
#  id                      :integer          not null, primary key
#  url                     :string(191)
#  position                :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  android_app_snapshot_id :integer
#

class AndroidAppSnapshotsScrSht < ActiveRecord::Base
  belongs_to :android_app_snapshot
end
