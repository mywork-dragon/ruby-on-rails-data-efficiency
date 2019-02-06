# == Schema Information
#
# Table name: ios_app_download_snapshots
#
#  id                               :integer          not null, primary key
#  downloads                        :integer
#  ios_app_id                       :integer
#  created_at                       :datetime
#  updated_at                       :datetime
#  ios_app_download_snapshot_job_id :integer
#  status                           :integer
#

class IosAppDownloadSnapshot < ActiveRecord::Base

  belongs_to :ios_app
  belongs_to :ios_app_download_snapshot_job
  has_many :ios_app_download_snapshot_exceptions
  
  enum status: [:failure, :success]
  
end
