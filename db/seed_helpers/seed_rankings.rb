def seed_rankings
  disable_logging
  puts 'creating iOS Rankings'
  
  iars = IosAppRankingSnapshot.create(kind: 0, is_valid: true)
  ios_ids = IosApp.pluck(:id)
  ios_ids.each do |app_id|
    IosAppRanking.create(ios_app_id: app_id, rank: app_id, ios_app_ranking_snapshot_id: iars.id)
  end

  aars = AndroidAppRankingSnapshot.create(kind: 0, is_valid: true)
  andr_ids = AndroidApp.pluck(:id)
  andr_ids.each do |app_id|
    AndroidAppRanking.create(android_app_id: app_id, rank: app_id, android_app_ranking_snapshot_id: aars.id)
  end

ensure
  enable_logging
end
