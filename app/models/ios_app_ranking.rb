class IosAppRanking < ActiveRecord::Base

  belongs_to :ios_app
  belongs_to :ios_app_ranking_snapshot

end