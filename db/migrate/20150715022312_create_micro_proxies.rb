class CreateMicroProxies < ActiveRecord::Migration
  def change
    create_table :micro_proxies do |t|
      t.boolean :active
      t.string :public_ip
      t.string :private_ip
      t.date :last_used

      t.timestamps
    end
    add_index :micro_proxies, :active
    add_index :micro_proxies, :public_ip
    add_index :micro_proxies, :private_ip
    add_index :micro_proxies, :last_used
  end
end
