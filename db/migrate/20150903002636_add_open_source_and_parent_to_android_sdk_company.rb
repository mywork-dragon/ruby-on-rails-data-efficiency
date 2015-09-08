class AddOpenSourceAndParentToAndroidSdkCompany < ActiveRecord::Migration
  def change
  	add_column :android_sdk_companies, :open_source, :boolean, default: false
  	add_column :android_sdk_companies, :parent_company_id, :integer

    add_index :android_sdk_companies, :open_source, name: 'android_sdk_companies_open_source_index'
  	add_index :android_sdk_companies, :parent_company_id, name: 'android_sdk_companies_parent_company_index'
  end
end
