class AddDataFlagToAndroidApp < ActiveRecord::Migration
  def change
  	add_column :android_apps, :data_flag, :boolean
  	add_index :android_apps, :data_flag
  end
end
