class AddIosAppSnapshotsIdNameIndex < ActiveRecord::Migration
  def change
    add_index :ios_app_snapshots, [:ios_app_id, :name]
  end
end
