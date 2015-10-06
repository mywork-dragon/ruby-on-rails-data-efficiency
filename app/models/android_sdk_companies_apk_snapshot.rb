class AndroidSdkCompaniesApkSnapshot < ActiveRecord::Base

  belongs_to :android_sdk_company
  belongs_to :apk_snapshot

end
