class AddDeveloperFieldsToApps < ActiveRecord::Migration
  def change
    add_column :ios_apps, :ios_developer_id, :integer
    add_column :android_apps, :android_developer_id, :integer
    add_index :ios_apps, :ios_developer_id
    add_index :android_apps, :android_developer_id
  end
end
