class ChangeAndroidAppSnapshotsScrShtsIdToBigint < ActiveRecord::Migration
  def change
    # change_column :android_app_snapshots_scr_shts, :id, :bigint, :null => false, :auto_increment => true
    # This migration would not complete in production because the table was too large. 
  end
end
