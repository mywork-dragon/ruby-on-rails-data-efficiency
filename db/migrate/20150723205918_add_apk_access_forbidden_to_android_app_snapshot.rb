class AddApkAccessForbiddenToAndroidAppSnapshot < ActiveRecord::Migration
  def change
  	add_column :android_app_snapshots, :apk_access_forbidden, :boolean
  	add_index :android_app_snapshots, :apk_access_forbidden, name: 'index_apk_access_forbidden'
  end
end
