class ChangeBacktraceToTextInIosAppSnapshotExceptions < ActiveRecord::Migration
  def change
    change_column :ios_app_snapshot_exceptions, :backtrace, :text
  end
end
