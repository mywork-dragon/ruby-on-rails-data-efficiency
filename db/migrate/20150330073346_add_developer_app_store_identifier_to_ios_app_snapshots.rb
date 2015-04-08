class AddDeveloperAppStoreIdentifierToIosAppSnapshots < ActiveRecord::Migration
  def change
    add_column :ios_app_snapshots, :developer_app_store_identifier, :integer
    add_index :ios_app_snapshots, :developer_app_store_identifier
  end
end
