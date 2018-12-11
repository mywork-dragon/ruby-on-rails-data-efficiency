# == Schema Information
#
# Table name: ios_app_snapshot_jobs
#
#  id         :integer          not null, primary key
#  notes      :text(65535)
#  created_at :datetime
#  updated_at :datetime
#

class IosAppSnapshotJob < ActiveRecord::Base

  has_many :ios_app_snapshots
  has_many :ios_app_snapshot_exceptions

end
