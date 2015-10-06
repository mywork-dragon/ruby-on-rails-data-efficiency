class CreateAndroidSdkCompany < ActiveRecord::Migration
  def change
    create_table :android_sdk_companies do |t|
    	t.string :name
    	t.string :website
    	t.string :favicon
    	t.boolean :flagged, default: false

    	t.timestamps
    end
    add_index :android_sdk_companies, :name
    add_index :android_sdk_companies, :website
    add_index :android_sdk_companies, :flagged
  end
end
