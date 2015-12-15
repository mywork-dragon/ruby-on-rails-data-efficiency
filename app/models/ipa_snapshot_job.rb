class IpaSnapshotJob < ActiveRecord::Base

  belongs_to :ios_app
  has_many :ipa_snapshots
  has_many :ipa_snapshot_job_exceptions
  has_many :ipa_snapshot_exceptions
  
  enum job_type: [:test, :one_off, :mass]
  enum live_scan_status: [:validating, :not_available, :paid, :unchanged, :device_incompatible, :initiated, :failed]
end
