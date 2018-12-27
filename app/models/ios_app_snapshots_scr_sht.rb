# == Schema Information
#
# Table name: ios_app_snapshots_scr_shts
#
#  id                  :integer          not null, primary key
#  url                 :string(191)
#  position            :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  ios_app_snapshot_id :integer
#

class IosAppSnapshotsScrSht < ActiveRecord::Base
  belongs_to :ios_app_snapshot
end
