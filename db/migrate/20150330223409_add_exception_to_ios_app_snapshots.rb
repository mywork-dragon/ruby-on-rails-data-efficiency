class AddExceptionToIosAppSnapshots < ActiveRecord::Migration
  def change
    add_column :ios_app_snapshots, :exception, :text
  end
end
