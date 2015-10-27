class RemoveTakenDownInAmericaAndDataFlagFromAndroidApp < ActiveRecord::Migration
  def change
  	remove_column :android_apps, :taken_down
  	remove_column :android_apps, :data_flag
  	remove_column :android_apps, :in_america
  end
end
