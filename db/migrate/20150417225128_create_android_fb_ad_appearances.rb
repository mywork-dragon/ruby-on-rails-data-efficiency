class CreateAndroidFbAdAppearances < ActiveRecord::Migration
  def change
    create_table :android_fb_ad_appearances do |t|
      t.string :aws_assignment_identifier
      t.string :hit_identifier
      t.integer :m_turk_worker_id
      t.integer :ios_app_id
      t.string :heroku_identifier

      t.timestamps
    end
    add_index :android_fb_ad_appearances, :aws_assignment_identifier
    add_index :android_fb_ad_appearances, :hit_identifier
    add_index :android_fb_ad_appearances, :m_turk_worker_id
    add_index :android_fb_ad_appearances, :ios_app_id
    add_index :android_fb_ad_appearances, :heroku_identifier
  end
end
