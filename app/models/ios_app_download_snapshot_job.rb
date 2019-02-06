# == Schema Information
#
# Table name: ios_app_download_snapshot_jobs
#
#  id         :integer          not null, primary key
#  notes      :string(191)
#  created_at :datetime
#  updated_at :datetime
#

class IosAppDownloadSnapshotJob < ActiveRecord::Base

  has_many :ios_app_download_snapshots
  has_many :ios_app_download_snapshot_exceptions

end
