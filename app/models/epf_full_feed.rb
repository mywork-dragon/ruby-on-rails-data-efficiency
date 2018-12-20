# == Schema Information
#
# Table name: epf_full_feeds
#
#  id         :integer          not null, primary key
#  name       :string(191)
#  created_at :datetime
#  updated_at :datetime
#

class EpfFullFeed < ActiveRecord::Base
  
  has_many :ios_app_epf_snapshots

  def date
    Date.parse(name)
  end
  
end
