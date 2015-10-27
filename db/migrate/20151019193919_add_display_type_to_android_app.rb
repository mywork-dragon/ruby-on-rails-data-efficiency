class AddDisplayTypeToAndroidApp < ActiveRecord::Migration
  def change
  	add_column :android_apps, :display_type, :integer, :default => 0
  	add_index :android_apps, :display_type
  end
end
