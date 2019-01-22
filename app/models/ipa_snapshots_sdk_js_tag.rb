# == Schema Information
#
# Table name: ipa_snapshots_sdk_js_tags
#
#  id              :integer          not null, primary key
#  ipa_snapshot_id :integer
#  sdk_js_tag_id   :integer
#  created_at      :datetime
#  updated_at      :datetime
#

class IpaSnapshotsSdkJsTag < ActiveRecord::Base
  belongs_to :ipa_snapshot
  belongs_to :sdk_js_tag
end
