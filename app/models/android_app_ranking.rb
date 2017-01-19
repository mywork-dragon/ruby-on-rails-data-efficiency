class AndroidAppRanking < ActiveRecord::Base
  has_many :android_apps
  belongs_to :android_app_ranking_snapshot
end
