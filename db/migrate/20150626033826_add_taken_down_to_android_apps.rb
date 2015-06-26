class AddTakenDownToAndroidApps < ActiveRecord::Migration
  def change
    add_column :android_apps, :taken_down, :boolean
    add_index :android_apps, :taken_down
  end
end
