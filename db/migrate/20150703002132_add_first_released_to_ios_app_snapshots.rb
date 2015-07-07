class AddFirstReleasedToIosAppSnapshots < ActiveRecord::Migration
  def change
    add_column :ios_app_snapshots, :first_released, :date unless column_exists?(:ios_app_snapshots, :first_released)
    add_index :ios_app_snapshots, :first_released unless index_exists?(:ios_app_snapshots, :first_released)
  end
end
