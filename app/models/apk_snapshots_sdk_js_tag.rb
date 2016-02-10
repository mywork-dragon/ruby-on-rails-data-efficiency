class ApkSnapshotsSdkJsTag < ActiveRecord::Base

  belongs_to :apk_snapshot
  belongs_to :sdk_js_tag

end
