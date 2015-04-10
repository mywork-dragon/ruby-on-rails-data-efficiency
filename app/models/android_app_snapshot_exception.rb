class AndroidAppSnapshotException < ActiveRecord::Base
  
  belongs_to :android_app_snapshot
  belongs_to :android_app_snapshot_job
  
  class << self
    
    def most_common(android_app_snapshot_job_id, limit=25)
      #self.where(android_app_snapshot_job_id: android_app_snapshot_job_id).group(:name).order('count_id DESC').limit(limit).count(:id)
      self.group(:name).order('count_id DESC').limit(limit).count(:id)
    end
    
  end
  
  
  
end
