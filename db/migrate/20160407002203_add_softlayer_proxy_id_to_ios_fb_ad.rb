class AddSoftlayerProxyIdToIosFbAd < ActiveRecord::Migration
  def change
    add_column :ios_fb_ads, :softlayer_proxy_id, :integer
    add_index :ios_fb_ads, :softlayer_proxy_id
  end
end
