class AddRegionToMicroProxies < ActiveRecord::Migration
  def change
    add_column :micro_proxies, :region, :integer
    add_index :micro_proxies, [:purpose, :region, :active]
  end
end
