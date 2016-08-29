class IosAppRankingSnapshot < ActiveRecord::Base

  has_many :ios_app_rankings
  has_many :ios_apps, through: :ios_app_rankings

  enum kind: [:itunes_top_free]

  def self.last_valid_snapshot
    where(is_valid: true).last
  end

  def self.top_200_app_ids
    IosAppRankingSnapshot.last_valid_snapshot ? IosAppRankingSnapshot.last_valid_snapshot.ios_app_rankings.pluck(:ios_app_id) : []
  end
end
