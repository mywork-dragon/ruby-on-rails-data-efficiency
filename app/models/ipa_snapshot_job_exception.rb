# == Schema Information
#
# Table name: ipa_snapshot_job_exceptions
#
#  id                  :integer          not null, primary key
#  ipa_snapshot_job_id :integer
#  error               :text(65535)
#  backtrace           :text(65535)
#  created_at          :datetime
#  updated_at          :datetime
#  ios_app_id          :integer
#

class IpaSnapshotJobException < ActiveRecord::Base
  belongs_to :ipa_snapshot_job
end
