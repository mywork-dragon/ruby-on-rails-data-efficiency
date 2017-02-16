class AddMoreIndicesToAndroidAds < ActiveRecord::Migration
  def change
    add_index :android_ads, :ad_id, :length => 23
  end
end
