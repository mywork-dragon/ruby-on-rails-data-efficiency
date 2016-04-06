class AddHostToSoftlayerProxies < ActiveRecord::Migration
  def change
    add_column :softlayer_proxies, :host, :integer
  end
end
