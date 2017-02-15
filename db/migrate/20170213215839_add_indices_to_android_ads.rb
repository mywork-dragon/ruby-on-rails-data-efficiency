class AddIndicesToAndroidAds < ActiveRecord::Migration
  def change
    add_index :android_ads, [:ad_type, :advertised_app_id]
    add_index :android_ads, [:advertised_app_id]
  end
end
