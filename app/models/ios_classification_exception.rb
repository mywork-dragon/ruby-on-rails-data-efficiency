# == Schema Information
#
# Table name: ios_classification_exceptions
#
#  id              :integer          not null, primary key
#  ipa_snapshot_id :integer
#  error           :text(65535)
#  backtrace       :text(65535)
#  created_at      :datetime
#  updated_at      :datetime
#

class IosClassificationException < ActiveRecord::Base
  belongs_to :ipa_snapshot
end
