class IpaSnapshotJob < ActiveRecord::Base

  has_many :ipa_snapshots
  has_many :ipa_snapshot_exceptions
  
  enum job_type: [:mock, :one_off, :mass]
  enum live_scan_status: [:validating, :initiated]
end
