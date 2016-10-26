class EpfFullFeed < ActiveRecord::Base
  
  has_many :ios_app_epf_snapshots

  def date
    Date.parse(name)
  end
  
end
