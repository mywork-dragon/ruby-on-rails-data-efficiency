class CreateAndroidSdkPackagePrefix < ActiveRecord::Migration
  def change
    create_table :android_sdk_package_prefixes do |t|
    	t.string :prefix
    	t.integer :android_sdk_company_id
    end
    add_index :android_sdk_package_prefixes, :prefix
    add_index :android_sdk_package_prefixes, :android_sdk_company_id
  end
end
