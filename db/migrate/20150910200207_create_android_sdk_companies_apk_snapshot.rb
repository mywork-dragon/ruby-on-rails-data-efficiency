class CreateAndroidSdkCompaniesApkSnapshot < ActiveRecord::Migration
  def change
    create_table :android_sdk_companies_apk_snapshots do |t|
    	t.integer :android_sdk_company_id
    	t.integer :apk_snapshot_id

    	t.timestamps
    end
    add_index :android_sdk_companies_apk_snapshots, [:apk_snapshot_id, :android_sdk_company_id], name: 'index_apk_snapshot_id_android_sdk_company_id'
    add_index :android_sdk_companies_apk_snapshots, :android_sdk_company_id, name: 'android_sdk_company_id'
  end
end