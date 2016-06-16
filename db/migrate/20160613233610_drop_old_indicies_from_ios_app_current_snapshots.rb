class DropOldIndiciesFromIosAppCurrentSnapshots < ActiveRecord::Migration
  def change
    remove_index :ios_app_current_snapshots, :by
    remove_index :ios_app_current_snapshots, :copyright
    remove_index :ios_app_current_snapshots, :editors_choice
    remove_index :ios_app_current_snapshots, :first_released
    remove_index :ios_app_current_snapshots, [:ios_app_id, :name]
    remove_index :ios_app_current_snapshots, [:ios_app_id, :released]
    remove_index :ios_app_current_snapshots, :name
    remove_index :ios_app_current_snapshots, :price
    remove_index :ios_app_current_snapshots, :ratings_all_count
    remove_index :ios_app_current_snapshots, :ratings_all_stars
    remove_index :ios_app_current_snapshots, :ratings_current_count
    remove_index :ios_app_current_snapshots, :ratings_current_stars
    remove_index :ios_app_current_snapshots, name: 'index_on_ratings_per_day_current_release'
    remove_index :ios_app_current_snapshots, :recommended_age
    remove_index :ios_app_current_snapshots, :released
    remove_index :ios_app_current_snapshots, :required_ios_version
    remove_index :ios_app_current_snapshots, :seller
    remove_index :ios_app_current_snapshots, :seller_url
    remove_index :ios_app_current_snapshots, :seller_url_text
    remove_index :ios_app_current_snapshots, :size
    remove_index :ios_app_current_snapshots, :status
    remove_index :ios_app_current_snapshots, :support_url
    remove_index :ios_app_current_snapshots, :support_url_text
    remove_index :ios_app_current_snapshots, :version
    remove_index :ios_app_current_snapshots, name: 'index_on_developer_app_store_identifier'
  end
end
