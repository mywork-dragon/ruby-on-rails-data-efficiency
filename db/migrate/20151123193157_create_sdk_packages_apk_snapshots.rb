class CreateSdkPackagesApkSnapshots < ActiveRecord::Migration
  def change
    create_table :sdk_packages_apk_snapshots do |t|

      t.timestamps
    end
  end
end
