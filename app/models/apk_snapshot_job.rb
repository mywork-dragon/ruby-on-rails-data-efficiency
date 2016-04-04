class ApkSnapshotJob < ActiveRecord::Base
  
  has_many :apk_snapshots
  has_many :apk_snapshot_scrape_failures
  has_many :apk_snapshot_scrape_exceptions

  enum job_type: [:test, :one_off, :mass]

  validates :job_type, presence: true
  
end
