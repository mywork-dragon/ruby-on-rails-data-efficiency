class AddRegionsToAndroidApps < ActiveRecord::Migration
  def change
    add_column :android_apps, :regions, :string, :default => "[]"
  end
end
