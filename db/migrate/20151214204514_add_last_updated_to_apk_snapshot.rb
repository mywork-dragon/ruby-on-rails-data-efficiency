class AddLastUpdatedToApkSnapshot < ActiveRecord::Migration
  def change
    add_column :apk_snapshots, :last_updated, :datetime
  end
end
