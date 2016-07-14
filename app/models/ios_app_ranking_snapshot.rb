class IosAppRankingSnapshot < ActiveRecord::Base

  has_many :ios_app_rankings
  has_many :ios_apps, through: :ios_app_rankings

  enum kind: [:itunes_top_free]

  def self.last_valid_snapshot
    where(is_valid: true).last
  end

end
