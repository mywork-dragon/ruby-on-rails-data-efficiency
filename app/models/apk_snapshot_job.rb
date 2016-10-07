class ApkSnapshotJob < ActiveRecord::Base
  
  has_many :apk_snapshots
  has_many :apk_snapshot_scrape_failures
  has_many :apk_snapshot_scrape_exceptions

  enum job_type: [:test, :one_off, :mass]

  enum ls_lookup_code: [:preparing, :initiated, :failed, :unavailable, :paid, :unchanged]
  enum ls_download_code: [:downloading, :retrying, :success, :failure]

  validates :job_type, presence: true
  
end
