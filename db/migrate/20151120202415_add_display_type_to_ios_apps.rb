class AddDisplayTypeToIosApps < ActiveRecord::Migration
  def change
    add_column :ios_apps, :display_type, :integer, :default => 0
    add_index :ios_apps, :display_type
  end
end
