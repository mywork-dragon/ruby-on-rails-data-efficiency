class AddLastScannedToApkSnapshots < ActiveRecord::Migration
  def change
     add_column :apk_snapshots, :last_scanned, :datetime
     add_index :apk_snapshots, :last_scanned
  end
end
