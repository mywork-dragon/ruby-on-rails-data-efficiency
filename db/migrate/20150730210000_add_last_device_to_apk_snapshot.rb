class AddLastDeviceToApkSnapshot < ActiveRecord::Migration
  def change
  	add_column :apk_snapshots, :last_device, :integer
  	add_index :apk_snapshots, :last_device
  end
end
