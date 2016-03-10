class AddVersionCodeToApkSnapshots < ActiveRecord::Migration
  def change
    add_column :apk_snapshots, :version_code, :integer
    add_index :apk_snapshots, :version_code
  end
end
