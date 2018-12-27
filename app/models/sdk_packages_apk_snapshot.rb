# == Schema Information
#
# Table name: sdk_packages_apk_snapshots
#
#  id              :integer          not null, primary key
#  sdk_package_id  :integer
#  apk_snapshot_id :integer
#  created_at      :datetime
#  updated_at      :datetime
#

class SdkPackagesApkSnapshot < ActiveRecord::Base

  belongs_to :sdk_package
  belongs_to :apk_snapshot

end
