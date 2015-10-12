class IpaSnapshot < ActiveRecord::Base

	belongs_to :class_dump
	belongs_to :ios_app

	has_many :ios_sdks_ipa_snapshots
	has_many :ios_sdks, through: :ios_sdks_ipa_snapshots

end
