class RemoveMobilePriorityFromAndroidModel < ActiveRecord::Migration
  def change
    remove_column :android_apps, :mobile_priority
  end
end
