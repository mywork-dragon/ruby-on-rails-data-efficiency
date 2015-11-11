class IosSdk < ActiveRecord::Base

	belongs_to :sdk_company

	has_many :ios_sdks_ipa_snapshots
  has_many :ipa_snapshots, through: :ios_sdks_ipa_snapshots
  has_many :cocoapods

end
