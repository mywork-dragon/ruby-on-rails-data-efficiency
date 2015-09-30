class ChangeNameOnIosAppSnapshotExceptionsToText < ActiveRecord::Migration
  def change
    change_column :ios_app_snapshot_exceptions, :name, :text
  end
end
