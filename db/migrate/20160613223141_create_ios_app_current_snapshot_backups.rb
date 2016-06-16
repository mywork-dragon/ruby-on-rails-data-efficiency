class CreateIosAppCurrentSnapshotBackups < ActiveRecord::Migration
  def change
    create_table :ios_app_current_snapshot_backups do |t|
      t.string :name
      t.integer :price
      t.integer :size
      t.string :seller_url
      t.string :support_url
      t.string :version
      t.date :released
      t.string :recommended_age
      t.text :description
      t.integer :ios_app_id
      t.string :required_ios_version
      t.integer :ios_app_current_snapshot_job_id
      t.text :release_notes
      t.string :seller
      t.integer :developer_app_store_identifier
      t.decimal :ratings_current_stars
      t.integer :ratings_current_count
      t.decimal :ratings_all_stars
      t.integer :ratings_all_count
      t.boolean :editors_choice
      t.integer :status
      t.text :icon_url_60x60
      t.text :icon_url_100x100
      t.text :icon_url_512x512
      t.decimal :ratings_per_day_current_release
      t.date :first_released
      t.string :by
      t.string :copyright
      t.string :seller_url_text
      t.string :support_url_text
      t.boolean :game_center_enabled
      t.string :bundle_identifier
      t.string :currency
      t.text :screenshot_urls
      t.integer :app_store_id
      t.integer :app_identifier
      t.integer :mobile_priority
      t.integer :user_base

      t.timestamps null: false
    end

    add_index :ios_app_current_snapshot_backups, :ios_app_id
    add_index :ios_app_current_snapshot_backups, :app_store_id
    add_index :ios_app_current_snapshot_backups, :app_identifier
    add_index :ios_app_current_snapshot_backups, :user_base
    add_index :ios_app_current_snapshot_backups, :mobile_priority
    add_index :ios_app_current_snapshot_backups, :ios_app_current_snapshot_job_id, name: 'index_ios_app_backup_on_job_id'
  end
end
