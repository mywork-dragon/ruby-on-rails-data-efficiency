class AddExceptionBacktraceToIosAppSnapshots < ActiveRecord::Migration
  def change
    add_column :ios_app_snapshots, :exception_backtrace, :text
  end
end
