class ChangeProxyTypeInApkSnapshots < ActiveRecord::Migration
  def change
    change_column :apk_snapshots, :proxy, :string
  end
end