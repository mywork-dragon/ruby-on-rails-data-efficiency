class CreateAndroidSdkCompaniesAndroidApp < ActiveRecord::Migration
  def change
    create_table :android_sdk_companies_android_apps do |t|
    	t.integer :android_sdk_company_id
    	t.integer :android_app_id

    	t.timestamps
    end
    add_index :android_sdk_companies_android_apps, [:android_app_id, :android_sdk_company_id], name: 'index_android_app_id_android_sdk_company_id'
    add_index :android_sdk_companies_android_apps, :android_sdk_company_id, name: 'android_sdk_company_id'
  end
end