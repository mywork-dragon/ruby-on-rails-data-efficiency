class AddApkAccessForbiddenToAndroidAppSnapshot < ActiveRecord::Migration
  def change
  	add_column :android_app_snapshots, :apk_access_forbidden, :boolean unless column_exists?(:android_app_snapshots, :apk_access_forbidden)
  	add_index :android_app_snapshots, :apk_access_forbidden, name: 'index_apk_access_forbidden' unless index_exists?(:android_app_snapshots, :apk_access_forbidden, name: 'index_apk_access_forbidden')
  end
end
