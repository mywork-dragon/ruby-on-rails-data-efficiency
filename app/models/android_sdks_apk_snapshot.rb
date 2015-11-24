class AndroidSdksApkSnapshot < ActiveRecord::Base

  belongs_to :android_sdk
  belongs_to :apk_snapshot

end
