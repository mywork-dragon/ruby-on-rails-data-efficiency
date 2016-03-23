class IndexScanStatusOnIpaSnapshots < ActiveRecord::Migration
  def change
    add_index :ipa_snapshots, :scan_status
  end
end
