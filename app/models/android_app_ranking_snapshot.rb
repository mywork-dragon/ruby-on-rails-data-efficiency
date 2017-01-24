class AndroidAppRankingSnapshot < ActiveRecord::Base

  has_many :android_app_rankings
  has_many :android_apps, through: :android_app_rankings

  enum kind: [:top_free]

  def self.last_valid_snapshot
    where(is_valid: true).last
  end

  def self.top_200_app_ids
    AndroidAppRankingSnapshot.last_valid_snapshot ? AndroidAppRankingSnapshot.last_valid_snapshot.android_app_rankings.pluck(:android_app_id) : []
  end
end
