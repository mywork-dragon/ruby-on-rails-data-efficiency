class AddFirstReleasedToIosAppSnapshots < ActiveRecord::Migration
  def change
    add_column :ios_app_snapshots, :first_released, :date
    add_index :ios_app_snapshots, :first_released
  end
end
