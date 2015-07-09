class AddTryToApkSnapshots < ActiveRecord::Migration
  def change
  	add_column :apk_snapshots, :try, :integer
  	add_index :apk_snapshots, :try
  end
end
