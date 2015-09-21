class AndroidSdkCompaniesApkSnapshot < ActiveRecord::Base

  belongs_to :android_sdk_company
  belongs_to :apk_snapshot

  validates_uniqueness_of :android_sdk_company_id, scope: :apk_snapshot_id

end
