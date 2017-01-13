class AddFbAppIdToIosApps < ActiveRecord::Migration
  def change
    add_column :ios_apps, :fb_app_id, :integer, limit: 8
    add_index :ios_apps, :fb_app_id
  end
end
