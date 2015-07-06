class CreateSuperProxies < ActiveRecord::Migration
  def change
    create_table :super_proxies do |t|
      t.boolean :active
      t.string :public_ip
      t.string :private_ip
      t.integer :port
      t.date :last_used

      t.timestamps
    end
    add_index :super_proxies, :active
    add_index :super_proxies, :public_ip
    add_index :super_proxies, :private_ip
    add_index :super_proxies, :port
    add_index :super_proxies, :last_used
  end
end
