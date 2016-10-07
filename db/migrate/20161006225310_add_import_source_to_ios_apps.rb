class AddImportSourceToIosApps < ActiveRecord::Migration
  def change
    add_column :ios_apps, :source, :integer
    add_index :ios_apps, :source
  end
end
