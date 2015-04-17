class CreateIosAppWebsites < ActiveRecord::Migration
  def change
    create_table :ios_app_websites do |t|
      t.integer :ios_app_id
      t.integer :website_id

      t.timestamps
    end
    add_index :ios_app_websites, :ios_app_id
    add_index :ios_app_websites, :website_id
  end
end
