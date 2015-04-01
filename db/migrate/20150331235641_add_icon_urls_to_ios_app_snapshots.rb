class AddIconUrlsToIosAppSnapshots < ActiveRecord::Migration
  def change
    add_column :ios_app_snapshots, :icon_url_350x350, :string
    add_column :ios_app_snapshots, :icon_url_175x175, :string 
  end
end
