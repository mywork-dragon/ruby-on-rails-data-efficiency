class IpaSnapshot < ActiveRecord::Base

	has_many :ios_sdks_ipa_snapshots
	has_many :ios_sdks, through: :ios_sdks_ipa_snapshots

end
