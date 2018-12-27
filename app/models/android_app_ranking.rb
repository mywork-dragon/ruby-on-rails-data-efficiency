# == Schema Information
#
# Table name: android_app_rankings
#
#  id                              :integer          not null, primary key
#  android_app_id                  :integer
#  android_app_ranking_snapshot_id :integer
#  rank                            :integer
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#

class AndroidAppRanking < ActiveRecord::Base
  has_many :android_apps
  belongs_to :android_app_ranking_snapshot
end
