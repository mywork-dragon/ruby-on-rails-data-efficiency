class CreateJpIosAppSnapshots < ActiveRecord::Migration
  def change
    create_table :jp_ios_app_snapshots do |t|
      t.string :name
      t.integer :price
      t.integer :size, limit: 8
      t.string :seller_url
      t.string :support_url
      t.string :version
      t.date :released
      t.string :recommended_age
      t.text :description
      t.integer :ios_app_id
      t.string :required_ios_version
      t.integer :ios_app_snapshot_job_id
      t.text :release_notes
      t.string :seller
      t.integer :developer_app_store_identifier
      t.decimal3 :ratings_current_stars
      t.decimal2 :ratings_current_stars
      t.integer :ratings_current_count
      t.decimal3 :ratings_all_stars
      t.decimal2 :ratings_all_stars
      t.integer :ratings_all_count
      t.boolean :editors_choice
      t.integer :status
      t.string :icon_url_350x350
      t.string :icon_url_175x175
      t.decimal10 :ratings_per_day_current_release
      t.decimal2 :ratings_per_day_current_release

      t.timestamps
    end
    add_index :jp_ios_app_snapshots, :name
    add_index :jp_ios_app_snapshots, :released
    add_index :jp_ios_app_snapshots, :ios_app_id
    add_index :jp_ios_app_snapshots, :ios_app_snapshot_job_id
    add_index :jp_ios_app_snapshots, :developer_app_store_identifier
  end
end
