class AndroidSdkPackagesApkSnapshot < ActiveRecord::Base

  belongs_to :android_sdk_package
  belongs_to :apk_snapshot

end
