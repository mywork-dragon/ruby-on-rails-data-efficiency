class ModifyIosAppCurrentSnapshots < ActiveRecord::Migration
  def change
    remove_column :ios_app_current_snapshots, :is_valid
    add_index :ios_app_current_snapshots, :user_base
  end
end
