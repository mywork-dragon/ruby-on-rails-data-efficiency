# == Schema Information
#
# Table name: ios_app_download_snapshot_exceptions
#
#  id                               :integer          not null, primary key
#  ios_app_download_snapshot_id     :integer
#  name                             :text(65535)
#  backtrace                        :text(65535)
#  try                              :integer
#  ios_app_download_snapshot_job_id :integer
#  created_at                       :datetime
#  updated_at                       :datetime
#

class IosAppDownloadSnapshotException < ActiveRecord::Base

  belongs_to :ios_app_download_snapshot
  belongs_to :ios_app_download_snapshot_job

end
