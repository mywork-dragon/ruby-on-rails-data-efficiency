# == Schema Information
#
# Table name: ipa_snapshots_sdk_dlls
#
#  id              :integer          not null, primary key
#  ipa_snapshot_id :integer
#  sdk_dll_id      :integer
#  created_at      :datetime
#  updated_at      :datetime
#

class IpaSnapshotsSdkDll < ActiveRecord::Base
  belongs_to :ipa_snapshot
  belongs_to :sdk_dll
end
