class CreateProxies < ActiveRecord::Migration
  def change
    create_table :proxies do |t|
      t.boolean :active
      t.string :public_ip
      t.string :private_ip
      t.datetime :last_used
      t.boolean :busy

      t.timestamps
    end
    add_index :proxies, :active
    add_index :proxies, :privateIp
    add_index :proxies, :lastUsed
    add_index :proxies, :busy
  end
end
