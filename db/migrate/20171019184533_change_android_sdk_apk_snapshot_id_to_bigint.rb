class ChangeAndroidSdkApkSnapshotIdToBigint < ActiveRecord::Migration
  def change
    change_column :android_sdks_apk_snapshots, :id, :bigint, :null => false, :auto_increment => true
  end
end
