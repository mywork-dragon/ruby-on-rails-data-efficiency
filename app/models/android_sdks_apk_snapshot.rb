class AndroidSdksApkSnapshot < ActiveRecord::Base
  belongs_to :android_sdk
  belongs_to :apk_snapshot

  enum method: [:packages, :dll_regexes, :js_tag_regexes]
end
