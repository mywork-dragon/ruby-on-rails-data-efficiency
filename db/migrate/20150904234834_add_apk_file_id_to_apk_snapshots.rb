class AddApkFileIdToApkSnapshots < ActiveRecord::Migration
  def change
  	add_column :apk_snapshots, :apk_file_id, :integer
  	add_index :apk_snapshots, :apk_file_id
  end
end
