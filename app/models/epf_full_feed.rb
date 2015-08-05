class EpfFullFeed < ActiveRecord::Base
  
  has_many :ios_app_epf_snapshots
  
end
