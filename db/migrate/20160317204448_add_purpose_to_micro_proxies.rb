class AddPurposeToMicroProxies < ActiveRecord::Migration
  def change
    remove_index :micro_proxies, name: 'index_micro_proxies_on_flags'
    remove_column :micro_proxies, :flags
    add_column :micro_proxies, :purpose, :integer
    add_index :micro_proxies, [:purpose, :active]
  end
end
