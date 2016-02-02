class CreateFbActivityJobs < ActiveRecord::Migration
  def change
    create_table :fb_activity_jobs do |t|
      t.text :notes
      t.timestamps
    end
  end
end
