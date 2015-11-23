class IpaSnapshotJob < ActiveRecord::Base

  has_many :ipa_snapshots
  has_many :ipa_snapshot_job_exceptions
  has_many :ipa_snapshot_exceptions
  
  enum job_type: [:mock, :one_off, :mass]
  enum live_scan_status: [:validating, :not_available, :paid, :unchanged, :device_incompatible, :initiated, :failed]
end
