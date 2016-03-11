class CreateIosFbAdExceptions < ActiveRecord::Migration
  def change
    create_table :ios_fb_ad_exceptions do |t|
      t.integer :ios_fb_ad_job_id
      t.integer :fb_account_id
      t.integer :ios_device_id
      t.text :error
      t.text :backtrace
      t.timestamps
    end

    add_index :ios_fb_ad_exceptions, :ios_fb_ad_job_id
    add_index :ios_fb_ad_exceptions, :fb_account_id
    add_index :ios_fb_ad_exceptions, :ios_device_id
  end
end
