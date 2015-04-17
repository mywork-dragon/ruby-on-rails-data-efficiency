class AddIconUrl300x300ToAndroidAppSnapshots < ActiveRecord::Migration
  def change
    
    add_column :android_app_snapshots, :icon_url_300x300, :string
    
  end
end
