class IpaSnapshotException < ActiveRecord::Base
  belongs_to :ipa_snapshot
  belongs_to :ipa_snapshot_job

  enum error_code: [:devices_busy, :ssh_failure]
end
