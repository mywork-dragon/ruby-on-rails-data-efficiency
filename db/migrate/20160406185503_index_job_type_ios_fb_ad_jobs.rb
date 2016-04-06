class IndexJobTypeIosFbAdJobs < ActiveRecord::Migration
  def change
    add_index :ios_fb_ad_jobs, :job_type
  end
end
