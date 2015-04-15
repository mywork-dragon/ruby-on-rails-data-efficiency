class AddUserBaseToAndroidApps < ActiveRecord::Migration
  def change
    add_column :android_apps, :user_base, :string
  end
end
