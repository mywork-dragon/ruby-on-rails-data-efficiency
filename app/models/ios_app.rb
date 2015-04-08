class IosApp < ActiveRecord::Base

  has_many :ios_app_snapshots
  belongs_to :app
  has_many :fb_ad_appearances
  
  def newest_snapshot
    self.ios_app_snapshots.max_by do |snapshot|
      snapshot.updated_at
    end
  end
  
end
