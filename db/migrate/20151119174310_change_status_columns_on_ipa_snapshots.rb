class ChangeStatusColumnsOnIpaSnapshots < ActiveRecord::Migration
  def change
    rename_column :ipa_snapshots, :status, :download_status
    add_column :ipa_snapshots, :scan_status, :integer
  end
end
