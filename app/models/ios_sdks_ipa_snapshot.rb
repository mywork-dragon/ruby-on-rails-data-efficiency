class IosSdksIpaSnapshot < ActiveRecord::Base

	belongs_to :ios_sdk
	belongs_to :ipa_snapshot

  enum method: [:classdump, :strings, :frameworks, :js_tag_regex, :file_regex, :string_regex]
	
end
