class CreateIosAppEpfSnapshots < ActiveRecord::Migration
  def change
    create_table :ios_app_epf_snapshots do |t|
      t.integer :export_date, limit: 8
      t.integer :application_id
      t.string :title
      t.string :recommended_age
      t.string :artist_name
      t.string :seller_name
      t.string :company_url
      t.string :support_url
      t.string :view_url
      t.string :artwork_url_large
      t.string :artwork_url_small
      t.datetime :itunes_release_date
      t.string :copywright
      t.text :description
      t.string :version
      t.string :itunes_version
      t.integer :download_size, limit: 8
      t.integer :epf_full_feed_id

      t.timestamps
    end
    add_index :ios_app_epf_snapshots, :export_date
    add_index :ios_app_epf_snapshots, :application_id
    add_index :ios_app_epf_snapshots, :title
    add_index :ios_app_epf_snapshots, :recommended_age
    add_index :ios_app_epf_snapshots, :artist_name
    add_index :ios_app_epf_snapshots, :seller_name
    add_index :ios_app_epf_snapshots, :company_url
    add_index :ios_app_epf_snapshots, :support_url
    add_index :ios_app_epf_snapshots, :view_url
    add_index :ios_app_epf_snapshots, :artwork_url_large
    add_index :ios_app_epf_snapshots, :artwork_url_small
    add_index :ios_app_epf_snapshots, :itunes_release_date
    add_index :ios_app_epf_snapshots, :copywright
    add_index :ios_app_epf_snapshots, :version
    add_index :ios_app_epf_snapshots, :itunes_version
    add_index :ios_app_epf_snapshots, :download_size
    add_index :ios_app_epf_snapshots, :epf_full_feed_id
  end
end
