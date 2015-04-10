class AddStatusToAndroidAppSnapshots < ActiveRecord::Migration
  def change
    add_column :android_app_snapshots, :status, :integer
  end
end
