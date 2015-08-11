class AddReleasedToIosApps < ActiveRecord::Migration
  def change
  	add_column :ios_apps, :released, :date
  	add_index :ios_apps, :released
  end
end
