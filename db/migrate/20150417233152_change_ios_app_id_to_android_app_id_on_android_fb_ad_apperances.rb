class ChangeIosAppIdToAndroidAppIdOnAndroidFbAdApperances < ActiveRecord::Migration
  def change
    rename_column :android_fb_ad_appearances, :ios_app_id, :android_app_id
  end
end
