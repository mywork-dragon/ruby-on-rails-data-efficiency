class CreateProxies < ActiveRecord::Migration
  def change
    create_table :proxies do |t|
      t.boolean :active
      t.string :publicIp
      t.string :privateIp
      t.datetime :lastUsed
      t.boolean :busy

      t.timestamps
    end
    add_index :proxies, :active
    add_index :proxies, :privateIp
    add_index :proxies, :lastUsed
    add_index :proxies, :busy
  end
end
