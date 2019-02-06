# == Schema Information
#
# Table name: ipa_snapshot_jobs
#
#  id                    :integer          not null, primary key
#  job_type              :integer
#  notes                 :text(65535)
#  created_at            :datetime
#  updated_at            :datetime
#  live_scan_status      :integer
#  international_enabled :boolean          default(FALSE)
#

class IpaSnapshotJob < ActiveRecord::Base

  belongs_to :ios_app
  has_many :ipa_snapshots
  has_many :ipa_snapshot_job_exceptions
  has_many :ipa_snapshot_exceptions
  has_many :ipa_snapshot_lookup_failures
  
  enum job_type: [:test, :one_off, :mass]
  enum live_scan_status: [:validating, :not_available, :paid, :unchanged, :device_incompatible, :initiated, :failed]
end
