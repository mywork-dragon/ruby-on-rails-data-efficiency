class CreateIosFbAds < ActiveRecord::Migration
  def change
    create_table :ios_fb_ads do |t|
      t.integer :ios_fb_ad_job_id
      t.integer :ios_app_id
      t.integer :fb_account_id
      t.integer :ios_device_id
      t.integer :status
      t.boolean :flagged, :default => false
      t.text :link_contents
      t.text :ad_info_html
      t.integer :feed_index
      t.boolean :carousel
      t.datetime :date_seen
      t.timestamps
    end

    add_index :ios_fb_ads, :ios_fb_ad_job_id
    add_index :ios_fb_ads, :fb_account_id
    add_index :ios_fb_ads, :ios_device_id
    add_index :ios_fb_ads, [:ios_app_id, :status, :flagged]
    add_index :ios_fb_ads, [:status, :flagged]
  end
end
