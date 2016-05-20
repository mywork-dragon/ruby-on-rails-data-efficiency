class CreateIosAppCurrentSnapshotsAndRelated < ActiveRecord::Migration
  def change
    create_table :ios_app_current_snapshots do |t|

      t.boolean :is_valid
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
      t.integer :ios_app_current_snapshot_job_id
      t.text :release_notes
      t.string :seller
      t.integer :developer_app_store_identifier
      t.decimal :ratings_current_stars, precision: 3, scale: 2
      t.integer :ratings_current_count
      t.decimal :ratings_all_stars, precision: 3, scale: 2
      t.integer :ratings_all_count
      t.boolean :editors_choice
      t.integer :status
      t.text :icon_url_60x60
      t.text :icon_url_100x100
      t.text :icon_url_512x512
      t.decimal :ratings_per_day_current_release, precision: 10, scale: 2
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

    # add_index :ios_app_current_snapshots

    # indexes from ios_app_snapshots table
    add_index :ios_app_current_snapshots, :ios_app_current_snapshot_job_id, name: 'index_on_ios_app_current_snapshot_job_id'
    add_index :ios_app_current_snapshots, :ios_app_id
    add_index :ios_app_current_snapshots, :developer_app_store_identifier, name: 'index_on_developer_app_store_identifier'
    add_index :ios_app_current_snapshots, :released
    add_index :ios_app_current_snapshots, [:ios_app_id, :released]
    add_index :ios_app_current_snapshots, [:ios_app_id, :name]
    add_index :ios_app_current_snapshots, :name
    add_index :ios_app_current_snapshots, :first_released
    add_index :ios_app_current_snapshots, :support_url
    add_index :ios_app_current_snapshots, :ratings_all_count
    
    # new indexes 
    add_index :ios_app_current_snapshots, :price
    add_index :ios_app_current_snapshots, :size
    add_index :ios_app_current_snapshots, :seller_url
    add_index :ios_app_current_snapshots, :version
    add_index :ios_app_current_snapshots, :recommended_age
    add_index :ios_app_current_snapshots, :required_ios_version
    add_index :ios_app_current_snapshots, :seller
    add_index :ios_app_current_snapshots, :ratings_current_stars
    add_index :ios_app_current_snapshots, :ratings_current_count
    add_index :ios_app_current_snapshots, :ratings_all_stars
    add_index :ios_app_current_snapshots, :editors_choice
    add_index :ios_app_current_snapshots, :status
    add_index :ios_app_current_snapshots, :ratings_per_day_current_release, name: 'index_on_ratings_per_day_current_release'
    add_index :ios_app_current_snapshots, :by
    add_index :ios_app_current_snapshots, :copyright
    add_index :ios_app_current_snapshots, :seller_url_text
    add_index :ios_app_current_snapshots, :support_url_text
    add_index :ios_app_current_snapshots, :app_store_id
    add_index :ios_app_current_snapshots, :app_identifier
    add_index :ios_app_current_snapshots, :mobile_priority

    create_table :ios_app_categories_current_snapshots do |t|
      t.integer :ios_app_category_id
      t.integer :ios_app_current_snapshot_id
      t.integer :kind
    end

    add_index :ios_app_categories_current_snapshots, [:ios_app_current_snapshot_id, :ios_app_category_id, :kind], name: 'index_on_ios_app_snapshot_ios_app_category_id_kind'
    add_index :ios_app_categories_current_snapshots, :ios_app_category_id, name: 'index_on_ios_app_category_id'
    add_index :ios_app_categories_current_snapshots, :kind

    create_table :ios_app_category_names do |t|
      t.string :name
      t.integer :app_store_id
      t.integer :ios_app_category_id
    end

    add_index :ios_app_category_names, [:ios_app_category_id, :app_store_id], name: 'index_on_ios_app_category_id_and_app_store_id'
    add_index :ios_app_category_names, :app_store_id
    add_index :ios_app_category_names, :name

    add_column :app_stores, :name, :string
    add_index :app_stores, :name

    # Add the iTunes category identifier
    add_column :ios_app_categories, :category_identifier, :integer
    add_index :ios_app_categories, :category_identifier 

  end
end