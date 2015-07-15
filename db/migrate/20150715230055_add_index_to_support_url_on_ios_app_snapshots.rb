class AddIndexToSupportUrlOnIosAppSnapshots < ActiveRecord::Migration
  def change
    add_index :ios_app_snapshots, :support_url
  end
end
