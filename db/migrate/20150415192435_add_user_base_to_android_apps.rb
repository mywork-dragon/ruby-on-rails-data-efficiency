class AddUserBaseToAndroidApps < ActiveRecord::Migration
  def change
    add_column :android_apps, :user_base, :integer
    add_index :android_apps, :user_base
  end
end
