# == Schema Information
#
# Table name: ipa_snapshot_exceptions
#
#  id                  :integer          not null, primary key
#  ipa_snapshot_id     :integer
#  ipa_snapshot_job_id :integer
#  error_code          :integer
#  error               :text(65535)
#  backtrace           :text(65535)
#  created_at          :datetime
#  updated_at          :datetime
#

class IpaSnapshotException < ActiveRecord::Base
  belongs_to :ipa_snapshot
  belongs_to :ipa_snapshot_job

  enum error_code: [:devices_busy, :ssh_failure]
end
