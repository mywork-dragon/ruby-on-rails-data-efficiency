# == Schema Information
#
# Table name: android_packages
#
#  id                  :integer          not null, primary key
#  package_name        :string(191)
#  apk_snapshot_id     :integer
#  android_package_tag :integer
#  created_at          :datetime
#  updated_at          :datetime
#  identified          :boolean
#  not_useful          :boolean
#

class AndroidPackage < ActiveRecord::Base

  belongs_to :apk_snapshot

end
