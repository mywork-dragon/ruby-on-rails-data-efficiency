class CreateFbActivities < ActiveRecord::Migration
  def change
    create_table :fb_activities do |t|
      t.integer :fb_activity_job_id
      t.integer :fb_account_id
      t.integer :likes
      t.text :status
      t.float :duration
      t.timestamps
    end

    add_index :fb_activities, :fb_activity_job_id
    add_index :fb_activities, :fb_account_id
  end
end
