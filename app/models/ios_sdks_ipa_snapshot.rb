class IosSdksIpaSnapshot < ActiveRecord::Base

	belongs_to :ios_sdk
	belongs_to :ipa_snapshot
	
end
