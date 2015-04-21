class AddIndexNameToIosAppSnapshots < ActiveRecord::Migration
  def change
    add_index :ios_app_snapshots, :name
  end
end
