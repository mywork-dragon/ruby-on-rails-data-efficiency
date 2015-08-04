class CreateSdkPackages < ActiveRecord::Migration
  def change
    create_table :sdk_packages do |t|
    	t.string :package_name
    	t.integer :sdk_company_id

    	t.timestamps
    end
    add_index :sdk_packages, :package_name
    add_index :sdk_packages, :sdk_company_id
  end
end
