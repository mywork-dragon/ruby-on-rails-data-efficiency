# == Schema Information
#
# Table name: ios_app_current_snapshot_jobs
#
#  id         :integer          not null, primary key
#  notes      :text(65535)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class IosAppCurrentSnapshotJob < ActiveRecord::Base
  has_many :ios_app_current_snapshots
  has_many :ios_app_current_snapshot_backups
end
