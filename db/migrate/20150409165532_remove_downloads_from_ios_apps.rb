class RemoveDownloadsFromIosApps < ActiveRecord::Migration
  def change
    remove_column :ios_apps, :downloads
  end
end
