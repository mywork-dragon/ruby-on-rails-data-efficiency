class IpaSnapshotLookupFailure < ActiveRecord::Base
  belongs_to :ios_app
  belongs_to :ipa_snapshot_job

  enum reason: [:no_data, :not_ios, :paid, :unchanged, :device_incompatible]
end
