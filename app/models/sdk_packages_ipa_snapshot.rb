# == Schema Information
#
# Table name: sdk_packages_ipa_snapshots
#
#  id              :integer          not null, primary key
#  sdk_package_id  :integer
#  ipa_snapshot_id :integer
#  created_at      :datetime
#  updated_at      :datetime
#

class SdkPackagesIpaSnapshot < ActiveRecord::Base

  belongs_to :sdk_package
  belongs_to :ipa_snapshot

end
