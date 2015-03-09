class ChangeAppIdColumnNameInApps < ActiveRecord::Migration
  def change
    
    rename_column :android_apps, :app_id, :app_identifier
    rename_column :ios_apps, :app_id, :app_identifier
    
  end
end
