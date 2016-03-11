class CreateIosFbAdJobs < ActiveRecord::Migration
  def change
    create_table :ios_fb_ad_jobs do |t|
      t.text :notes
      t.timestamps
    end
  end
end
