class CreateOpenProxies < ActiveRecord::Migration
  def change
    create_table :open_proxies do |t|
      t.string :public_ip
      t.string :username
      t.string :password
      t.integer :port
      t.integer :kind

      t.timestamps null: false
    end
    add_index :open_proxies, :public_ip
    add_index :open_proxies, :kind
  end
end
