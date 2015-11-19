class AddLiveScanStatusToIpaSnapshotJobs < ActiveRecord::Migration
  def change
    add_column :ipa_snapshot_jobs, :live_scan_status, :integer
  end
end
