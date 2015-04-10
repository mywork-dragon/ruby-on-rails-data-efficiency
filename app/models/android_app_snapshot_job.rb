class AndroidAppSnapshotJob < ActiveRecord::Base
  
  has_many :android_app_snapshots
  has_many :android_app_snapshot_exceptions
  

end
