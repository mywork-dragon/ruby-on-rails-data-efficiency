class AddSoftlayerProxyIdToIosDevices < ActiveRecord::Migration
  def change
    add_column :ios_devices, :softlayer_proxy_id, :integer
    add_index :ios_devices, :softlayer_proxy_id
  end
end
