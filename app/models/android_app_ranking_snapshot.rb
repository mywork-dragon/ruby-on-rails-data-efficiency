class AndroidAppRankingSnapshot < ActiveRecord::Base

  has_many :android_app_rankings
  has_many :android_apps, through: :android_app_rankings

  enum kind: [:top_free]
end
