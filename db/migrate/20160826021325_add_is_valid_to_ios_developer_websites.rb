class AddIsValidToIosDeveloperWebsites < ActiveRecord::Migration
  def change
    add_column :ios_developers_websites, :is_valid, :bool, default: true
    add_column :android_developers_websites, :is_valid, :bool, default: true
    add_index :ios_developers_websites, [:ios_developer_id, :is_valid], name: 'ios_developers_websites_is_valid'
    add_index :android_developers_websites, [:android_developer_id, :is_valid], name: 'android_developers_websites_is_valid'
  end
end
