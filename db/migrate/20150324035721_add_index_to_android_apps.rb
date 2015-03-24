class AddIndexToAndroidApps < ActiveRecord::Migration
  def change
    add_index :android_apps, :app_identifier
  end
end
