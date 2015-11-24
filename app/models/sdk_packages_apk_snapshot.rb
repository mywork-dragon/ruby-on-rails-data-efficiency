class SdkPackagesApkSnapshot < ActiveRecord::Base

  belongs_to :sdk_package
  belongs_to :apk_snapshot

end
