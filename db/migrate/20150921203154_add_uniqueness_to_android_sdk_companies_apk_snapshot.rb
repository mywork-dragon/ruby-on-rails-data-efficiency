class AddUniquenessToAndroidSdkCompaniesApkSnapshot < ActiveRecord::Migration
  def change

  	# remove_index :android_sdk_companies_apk_snapshots, name: 'index_apk_snapshot_id_android_sdk_company_id'

    add_index :android_sdk_companies_apk_snapshots, [:apk_snapshot_id, :android_sdk_company_id], :unique => true, name: 'index_uniq_apk_snapshot_id_android_sdk_company_id'

  end
end
