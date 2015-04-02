class AddIconUrlsToIosAppSnapshots < ActiveRecord::Migration
  def change
    add_column :ios_app_snapshots, :icon_url_350x350, :string unless ActiveRecord::Base.connection.column_exists?(:ios_app_snapshots, :icon_url_350x350)
    add_column :ios_app_snapshots, :icon_url_175x175, :string unless ActiveRecord::Base.connection.column_exists?(:ios_app_snapshots, :icon_url_175x175)
  end
end
