# == Schema Information
#
# Table name: android_app_snapshot_jobs
#
#  id         :integer          not null, primary key
#  notes      :text(65535)
#  created_at :datetime
#  updated_at :datetime
#

class AndroidAppSnapshotJob < ActiveRecord::Base
  
  has_many :android_app_snapshots
  has_many :android_app_snapshot_exceptions
  

end
