class AddStatusToIosAppSnapshots < ActiveRecord::Migration
  def change
    add_column :ios_app_snapshots, :status, :integer
  end
end
