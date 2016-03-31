class AddIosFbAdAppearancesToIosFbAds < ActiveRecord::Migration
  def change
    add_column :ios_fb_ads, :ios_fb_ad_appearances_id, :integer
    add_index :ios_fb_ads, :ios_fb_ad_appearances_id
  end
end
