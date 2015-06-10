class RemoveExtraDemoColumnFromJpIosAppSnapshots < ActiveRecord::Migration
  def change
    
    remove_column :jp_ios_app_snapshots, :released
    remove_column :jp_ios_app_snapshots, :editors_choice
    remove_column :jp_ios_app_snapshots, :icon_url_350x350
    remove_column :jp_ios_app_snapshots, :icon_url_175x175
    remove_column :jp_ios_app_snapshots, :ratings_per_day_current_release
    remove_column :jp_ios_app_snapshots, :mobile_priority
    
  end
end
