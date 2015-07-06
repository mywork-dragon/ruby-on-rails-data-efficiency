class AddPortPrivateIpIndexToSuperProxies < ActiveRecord::Migration
  def change
    add_index :super_proxies, [:port, :private_ip]
  end
end
