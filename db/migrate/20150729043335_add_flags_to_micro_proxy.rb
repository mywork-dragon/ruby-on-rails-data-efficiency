class AddFlagsToMicroProxy < ActiveRecord::Migration
  def change
  	add_column :micro_proxies, :flags, :integer
  	add_index :micro_proxies, :flags
  end
end
