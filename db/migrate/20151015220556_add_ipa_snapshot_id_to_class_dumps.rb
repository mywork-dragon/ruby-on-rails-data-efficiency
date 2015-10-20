class AddIpaSnapshotIdToClassDumps < ActiveRecord::Migration
  def change
  	add_column :class_dumps, :ipa_snapshot_id, :integer
  	add_index :class_dumps, :ipa_snapshot_id
  end
end
