class RemoveBusyFromProxies < ActiveRecord::Migration
  def change
    remove_column :proxies, :busy
  end
end
