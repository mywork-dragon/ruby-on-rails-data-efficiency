class AddRegionToApkSnapshots < ActiveRecord::Migration
  def change
    add_column :apk_snapshots, :region, :integer
  end
end
