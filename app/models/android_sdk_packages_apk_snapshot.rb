# == Schema Information
#
# Table name: android_sdk_packages_apk_snapshots
#
#  id                     :integer          not null, primary key
#  android_sdk_package_id :integer
#  apk_snapshot_id        :integer
#  created_at             :datetime
#  updated_at             :datetime
#

class AndroidSdkPackagesApkSnapshot < ActiveRecord::Base

  belongs_to :android_sdk_package
  belongs_to :apk_snapshot

end
