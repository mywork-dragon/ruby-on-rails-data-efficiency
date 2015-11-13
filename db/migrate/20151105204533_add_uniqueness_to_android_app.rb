class AddUniquenessToAndroidApp < ActiveRecord::Migration
  def change
    remove_index :android_apps, name: 'index_android_apps_on_app_identifier'
    add_index :android_apps, :app_identifier, unique: true
  end
end
