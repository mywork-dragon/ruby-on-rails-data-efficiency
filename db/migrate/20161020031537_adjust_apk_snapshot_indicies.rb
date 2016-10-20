class AdjustApkSnapshotIndicies < ActiveRecord::Migration
  def change
    add_index :apk_snapshots, [:status, :scan_status]
  end
end
