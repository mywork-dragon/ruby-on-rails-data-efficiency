class AddProxyToApkSnapshots < ActiveRecord::Migration
  def change
  	add_column :apk_snapshots, :proxy, :integer
  	add_index :apk_snapshots, :proxy
  end
end
