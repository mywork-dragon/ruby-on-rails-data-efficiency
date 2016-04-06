class AddJobTypeToIosFbAdJobs < ActiveRecord::Migration
  def change
    add_column :ios_fb_ad_jobs, :job_type, :integer
  end
end
