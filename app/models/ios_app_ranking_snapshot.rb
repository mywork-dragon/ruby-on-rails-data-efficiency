class IosAppRankingSnapshot < ActiveRecord::Base

  has_many :ios_app_rankings

  enum kind: [:itunes_top_free]

end