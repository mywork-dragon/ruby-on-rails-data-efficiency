class IosSdksIpaSnapshot < ActiveRecord::Base

	belongs_to :ios_sdk
	belongs_to :ipa_snapshot

  enum method: [:classdump, :strings, :frameworks]
	
end
