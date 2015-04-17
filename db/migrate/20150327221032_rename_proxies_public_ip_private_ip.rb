class RenameProxiesPublicIpPrivateIp < ActiveRecord::Migration
  def change
    rename_column :proxies, :privateIp, :private_ip
    rename_column :proxies, :publicIp, :public_ip
    rename_column :proxies, :lastUsed, :last_used
  end
end
