class AddAppStoreAndGooglePlayIds < ActiveRecord::Migration
  def change
    
    add_column :ios_apps, :app_id, :integer
    add_column :android_apps, :app_id, :string
    
  end
end
