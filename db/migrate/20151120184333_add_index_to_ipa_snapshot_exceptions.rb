class AddIndexToIpaSnapshotExceptions < ActiveRecord::Migration
  def change
    add_index :ipa_snapshot_exceptions, :ipa_snapshot_id
  end
end
