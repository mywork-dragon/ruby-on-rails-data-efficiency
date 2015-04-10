class CreateAndroidAppsWebsites < ActiveRecord::Migration
  def change
    create_table :android_apps_websites do |t|
      t.integer :android_app_id
      t.integer :website_id

      t.timestamps
    end
    add_index :android_apps_websites, :android_app_id
    add_index :android_apps_websites, :website_id
  end
end
