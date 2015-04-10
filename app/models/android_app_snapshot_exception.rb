class AndroidAppSnapshotException < ActiveRecord::Base
  
  belongs_to :android_app_snapshot
  belongs_to :android_app_snapshot_job
  
  class << self
    
    def most_common(android_app_snapshot_job_id=nil, options={})
      limit = options[:limit]
      limit = 25 if limit.nil?
      
      if android_app_snapshot_job_id
        return self.where(android_app_snapshot_job_id: android_app_snapshot_job_id).group(:name).order('count_id DESC').limit(limit).count(:id)
      else
        return self.group(:name).order('count_id DESC').limit(limit).count(:id)
      end
      
    end
    
  end
  
  
  
end
