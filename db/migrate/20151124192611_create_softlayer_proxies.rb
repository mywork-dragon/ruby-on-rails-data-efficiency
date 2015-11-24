class CreateSoftlayerProxies < ActiveRecord::Migration
  def change
    create_table :softlayer_proxies do |t|
      t.string :public_ip

      t.timestamps
    end
    add_index :softlayer_proxies, :public_ip
  end
end
