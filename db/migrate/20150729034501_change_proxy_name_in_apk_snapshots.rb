class ChangeProxyNameInApkSnapshots < ActiveRecord::Migration
  def change
  	remove_index :apk_snapshots, name: 'index_apk_snapshots_on_proxy'
  	remove_column :apk_snapshots, :proxy, :string
    add_column :apk_snapshots, :micro_proxy_id, :integer
    add_index :apk_snapshots, :micro_proxy_id
  end
end
