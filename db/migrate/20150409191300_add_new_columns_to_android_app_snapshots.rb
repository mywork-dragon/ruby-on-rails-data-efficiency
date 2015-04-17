class AddNewColumnsToAndroidAppSnapshots < ActiveRecord::Migration
  def change
    
    add_column :android_app_snapshots, :seller, :string
    add_column :android_app_snapshots, :ratings_all_stars, :decimal, precision: 3, scale: 2
    add_column :android_app_snapshots, :ratings_all_count, :integer
    
  end
end
