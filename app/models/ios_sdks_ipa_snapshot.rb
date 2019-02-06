# == Schema Information
#
# Table name: ios_sdks_ipa_snapshots
#
#  id              :integer          not null, primary key
#  ios_sdk_id      :integer
#  ipa_snapshot_id :integer
#  created_at      :datetime
#  updated_at      :datetime
#  method          :integer
#

class IosSdksIpaSnapshot < ActiveRecord::Base

	belongs_to :ios_sdk
	belongs_to :ipa_snapshot

  enum method: [:classdump, :strings, :frameworks, :js_tag_regex, :file_regex, :string_regex, :dll_regex]
	
end
