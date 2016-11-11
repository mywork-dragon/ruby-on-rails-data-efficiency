class AddIndexToDateSeenOnFbAds < ActiveRecord::Migration
  def change
    add_index :ios_fb_ads, :date_seen
  end
end
