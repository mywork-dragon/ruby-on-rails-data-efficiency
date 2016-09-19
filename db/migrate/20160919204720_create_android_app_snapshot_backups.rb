class CreateAndroidAppSnapshotBackups < ActiveRecord::Migration
  def change
    create_table :android_app_snapshot_backups do |t|
      t.string   "name"
      t.integer  "price"
      t.integer  "size",                             limit: 8
      t.date     "updated"
      t.string   "seller_url"
      t.string   "version"
      t.date     "released"
      t.text     "description"
      t.integer  "android_app_id"
      t.integer  "google_plus_likes"
      t.boolean  "top_dev"
      t.boolean  "in_app_purchases"
      t.string   "required_android_version"
      t.string   "content_rating"
      t.string   "seller"
      t.decimal  "ratings_all_stars", precision: 3, scale: 2
      t.integer  "ratings_all_count"
      t.integer  "status"
      t.integer  "android_app_snapshot_job_id"
      t.integer  "in_app_purchase_min"
      t.integer  "in_app_purchase_max"
      t.integer  "downloads_min", limit: 8
      t.integer  "downloads_max", limit: 8
      t.string   "icon_url_300x300"
      t.string   "developer_google_play_identifier"
      t.boolean  "apk_access_forbidden"
    end

    add_index :android_app_snapshot_backups, ["android_app_id", "name"]
    add_index :android_app_snapshot_backups, ["android_app_id", "released"], name: 'index_android_app_snapshot_bck_app_released'
    add_index :android_app_snapshot_backups, ["android_app_snapshot_job_id"], name: 'index_android_app_snapshot_bck_job_id'
    add_index :android_app_snapshot_backups, ["developer_google_play_identifier"], name: 'index_android_app_snapshot_bck_dev_id'
    add_index :android_app_snapshot_backups, ["downloads_min"], name: 'index_android_app_snapshot_bck_dwnld_min'
    add_index :android_app_snapshot_backups, ["name"]
    add_index :android_app_snapshot_backups, ["released"]
  end
end
