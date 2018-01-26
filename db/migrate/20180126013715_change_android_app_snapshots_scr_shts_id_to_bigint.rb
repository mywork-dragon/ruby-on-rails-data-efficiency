class ChangeAndroidAppSnapshotsScrShtsIdToBigint < ActiveRecord::Migration
  def change
    change_column :android_app_snapshots_scr_shts, :id, :bigint, :null => false, :auto_increment => true
  end
end
