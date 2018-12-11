# == Schema Information
#
# Table name: ipa_snapshot_lookup_failures
#
#  id                  :integer          not null, primary key
#  ipa_snapshot_job_id :integer
#  ios_app_id          :integer
#  reason              :integer
#  lookup_content      :text(65535)
#  created_at          :datetime
#  updated_at          :datetime
#

class IpaSnapshotLookupFailure < ActiveRecord::Base
  belongs_to :ios_app
  belongs_to :ipa_snapshot_job

  enum reason: [:no_data, :not_ios, :paid, :unchanged, :device_incompatible, :no_stores]
end
