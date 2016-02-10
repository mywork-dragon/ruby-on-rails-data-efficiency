class ApkSnapshotsSdkDll < ActiveRecord::Base

  belongs_to :apk_snapshot
  belongs_to :sdk_dll

end
