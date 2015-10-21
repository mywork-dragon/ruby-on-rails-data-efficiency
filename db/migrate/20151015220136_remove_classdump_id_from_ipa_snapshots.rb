class RemoveClassdumpIdFromIpaSnapshots < ActiveRecord::Migration
  def change
  	remove_column :ipa_snapshots, :class_dump_id
  end
end
