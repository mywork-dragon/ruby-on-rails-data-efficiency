class CreateAndroidSdkPackage < ActiveRecord::Migration
  def change
    create_table :android_sdk_packages do |t|
    	t.string :package_name
    	# t.integer :android_sdk_company_id
    	t.integer :android_sdk_package_prefix_id

    	t.timestamps
    end
    add_index :android_sdk_packages, :package_name
    add_index :android_sdk_packages, :android_sdk_package_prefix_id
    # add_index :android_sdk_packages, :android_sdk_company_id
  end
end
