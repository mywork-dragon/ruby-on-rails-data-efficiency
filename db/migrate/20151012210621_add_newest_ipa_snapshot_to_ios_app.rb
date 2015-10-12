class AddNewestIpaSnapshotToIosApp < ActiveRecord::Migration
  def change
  	add_column :ios_apps, :newest_ipa_snapshot_id, :integer
  	add_index :ios_apps, :newest_ipa_snapshot_id
  end
end
