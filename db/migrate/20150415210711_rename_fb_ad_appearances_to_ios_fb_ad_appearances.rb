class RenameFbAdAppearancesToIosFbAdAppearances < ActiveRecord::Migration
  def change
    rename_table :fb_ad_appearances, :ios_fb_ad_appearances
  end
end
