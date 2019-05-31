def seed_fb_ads
  disable_logging

  puts 'creating FB Ads'
  IosApp.pluck(:id).each do |id|
    rand(2..6).times do
      IosFbAd.create(ios_app_id: id, date_seen: Faker::Date.between(1.year.ago, Date.today))
    end
  end

  puts 'creating Android Ads'
  AndroidApp.pluck(:id).each do |id|
    rand(2..6).times do
      AndroidAd.create(advertised_app_id: id, date_seen: Faker::Date.between(1.year.ago, Date.today))
    end
  end
ensure
  enable_logging
end
