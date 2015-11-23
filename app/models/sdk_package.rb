class SdkPackage < ActiveRecord::Base

	belongs_to :ios_sdk
  belongs_to :android_sdk

  has_many :sdk_packages_apk_snapshots
  has_many :apk_snapshots, through: :sdk_packages_apk_snapshots

  has_many :sdk_packages_ipa_snapshots
  has_many :ipa_snapshots, through: :sdk_packages_ipa_snapshots

end
