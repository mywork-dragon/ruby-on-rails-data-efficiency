class AddUniquenessToAndroidSdkCompaniesApkSnapshotNewer < ActiveRecord::Migration
  def change

  	remove_index :android_sdk_companies_apk_snapshots, name: 'index_apk_snapshot_id_android_sdk_company_id_4'

    add_index :android_sdk_companies_apk_snapshots, [:apk_snapshot_id, :android_sdk_company_id], unique: true, name: 'index_apk_snapshot_id_android_sdk_company_id_unique' 

  end
end
