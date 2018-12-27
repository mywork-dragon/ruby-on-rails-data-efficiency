# == Schema Information
#
# Table name: apk_snapshot_jobs
#
#  id               :integer          not null, primary key
#  notes            :text(65535)
#  is_fucked        :boolean
#  created_at       :datetime
#  updated_at       :datetime
#  job_type         :integer
#  ls_lookup_code   :integer
#  ls_download_code :integer
#

class ApkSnapshotJob < ActiveRecord::Base
  
  has_many :apk_snapshots
  has_many :apk_snapshot_exceptions
  has_many :apk_snapshot_scrape_failures
  has_many :apk_snapshot_scrape_exceptions

  enum job_type: [:test, :one_off, :mass, :weekly_mass]

  enum ls_lookup_code: [:preparing, :initiated, :failed, :unavailable, :paid, :unchanged]
  enum ls_download_code: [:downloading, :retrying, :success, :failure]

  validates :job_type, presence: true
  
end
