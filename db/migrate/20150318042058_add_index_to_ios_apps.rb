class AddIndexToIosApps < ActiveRecord::Migration
  def change
    
    add_index :ios_apps, :app_identifier
    
  end
end
