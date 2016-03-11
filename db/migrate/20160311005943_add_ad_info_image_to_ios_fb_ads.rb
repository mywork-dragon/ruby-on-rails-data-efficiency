class AddAdInfoImageToIosFbAds < ActiveRecord::Migration
  def up
      add_attachment :ios_fb_ads, :ad_info_image
    end

    def down
      remove_attachment :ios_fb_ads, :ad_info_image
    end
end
