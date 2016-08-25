class AddOpenProxyIdToIosFbAdsAndIosDevices < ActiveRecord::Migration
  def change

    add_column :ios_fb_ads, :open_proxy_id, :integer
    add_index :ios_fb_ads, :open_proxy_id

    add_column :ios_devices, :open_proxy_id, :integer
    add_index :ios_devices, :open_proxy_id

  end
end
