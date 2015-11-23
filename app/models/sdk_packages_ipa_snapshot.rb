class SdkPackagesIpaSnapshot < ActiveRecord::Base

  belongs_to :sdk_package
  belongs_to :ipa_snapshot

end
