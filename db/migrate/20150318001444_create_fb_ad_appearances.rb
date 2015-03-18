class CreateFbAdAppearances < ActiveRecord::Migration
  def change
    create_table :fb_ad_appearances do |t|
      t.string :aws_assignment_identifier
      t.string :hit_identifier
      t.integer :heroku_identifier
      t.integer :m_turk_worker_id
      t.integer :ios_app_id

      t.timestamps
    end
  end
end
