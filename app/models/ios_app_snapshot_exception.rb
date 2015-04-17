class IosAppSnapshotException < ActiveRecord::Base

  belongs_to :ios_app_snapshot
  belongs_to :ios_app_snapshot_job
  
  class << self
    
    def most_common(ios_app_snapshot_job_id=nil, options={})
      limit = options[:limit]
      limit = 5 if limit.nil?
      
      if ios_app_snapshot_job_id
        return self.where(ios_app_snapshot_job_id: ios_app_snapshot_job_id).group(:name).order('count_id DESC').limit(limit).count(:id)
      else
        return self.group(:name).order('count_id DESC').limit(limit).count(:id)
      end
      
    end
    
  end
  

end
