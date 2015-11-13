class IpaSnapshot < ActiveRecord::Base

	has_many :class_dumps
  has_many :ipa_snapshot_exceptions

	belongs_to :ios_app
  belongs_to :ipa_snapshot_job

	has_many :ios_sdks_ipa_snapshots
	has_many :ios_sdks, through: :ios_sdks_ipa_snapshots

  enum status: [:starting, :retrying, :cleaning, :complete]
end
