class AddScanStatusIndexToIpaSnapshots < ActiveRecord::Migration
  def change
    remove_index :ipa_snapshots, :ios_app_id
    add_index :ipa_snapshots, [:ios_app_id, :scan_status]
  end
end
