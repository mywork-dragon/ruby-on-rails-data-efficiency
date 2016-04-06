class IndexHostOnSoftlayerProxies < ActiveRecord::Migration
  def change
    add_index :softlayer_proxies, :host
  end
end
