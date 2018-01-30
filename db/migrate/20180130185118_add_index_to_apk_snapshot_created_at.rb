class AddIndexToApkSnapshotCreatedAt < ActiveRecord::Migration
  def change
    add_index :apk_snapshots, :created_at
  end
end
