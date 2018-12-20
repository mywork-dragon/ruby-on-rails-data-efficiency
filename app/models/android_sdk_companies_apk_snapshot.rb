# == Schema Information
#
# Table name: android_sdk_companies_apk_snapshots
#
#  id                     :integer          not null, primary key
#  android_sdk_company_id :integer
#  apk_snapshot_id        :integer
#  created_at             :datetime
#  updated_at             :datetime
#

class AndroidSdkCompaniesApkSnapshot < ActiveRecord::Base

  belongs_to :android_sdk_company
  belongs_to :apk_snapshot

  validates_uniqueness_of :android_sdk_company_id, scope: :apk_snapshot_id

end
