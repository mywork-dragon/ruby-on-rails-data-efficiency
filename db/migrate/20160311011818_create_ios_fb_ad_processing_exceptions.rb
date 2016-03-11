class CreateIosFbAdProcessingExceptions < ActiveRecord::Migration
  def change
    create_table :ios_fb_ad_processing_exceptions do |t|
      t.integer :ios_fb_ad_id
      t.text :error
      t.text :backtrace
      t.timestamps
    end

    add_index :ios_fb_ad_processing_exceptions, :ios_fb_ad_id
  end
end
