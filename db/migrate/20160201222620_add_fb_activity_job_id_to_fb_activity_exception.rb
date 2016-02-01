class AddFbActivityJobIdToFbActivityException < ActiveRecord::Migration
  def change
    add_column :fb_activity_exceptions, :fb_activity_job_id, :integer
    add_index :fb_activity_exceptions, :fb_activity_job_id
  end
end
