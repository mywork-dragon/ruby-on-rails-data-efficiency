# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

if Rails.env.development?

  puts "creating categories..."
  categories = ["Games", "Lifestyle", "Shopping", "Social", "Entertainment", "News", "Education", "Medical", "Productivity", "Music", "Photography"]
  categories.each do |cat|
    IosAppCategory.find_or_create_by(name: cat)
    AndroidAppCategory.find_or_create_by(name: cat)
  end

  puts "creating ios and android apps, and creating one snapshot for each..."
  for i in 1..500
    name = Faker::App.name
    
    ios_app = IosApp.find_or_create_by(app_identifier: i)
    ios_app_snapshot = IosAppSnapshot.create(name: name, released: Faker::Time.between(2.years.ago, Time.now), ios_app_id: IosApp.all.sample.id, icon_url_350x350: Faker::Avatar.image("#{name}#{i}350", "350x350"), icon_url_175x175: Faker::Avatar.image("#{name}#{i}175"), price: Faker::Commerce.price, size: rand(1000..1000000), version: Faker::App.version, description: Faker::Lorem.paragraph, release_notes: Faker::Lorem.paragraph, ratings_current_stars: rand(0..5), ratings_current_count: rand(0..100), ratings_all_stars: rand(0..5), ratings_all_count: rand(100..500))
    ios_app.ios_app_snapshots << ios_app_snapshot
    ios_cat = IosAppCategory.all.sample
    ios_cat.ios_app_snapshots << ios_app_snapshot
    
    android_app = AndroidApp.find_or_create_by(app_identifier: "com.company#{i}")
    android_app_snapshot = AndroidAppSnapshot.create(name: name, released: Faker::Time.between(2.years.ago, Time.now), android_app_id: AndroidApp.all.sample.id, icon_url_300x300: Faker::Avatar.image("#{name}#{i}300", "300x300"), price: Faker::Commerce.price, size: rand(1000..1000000), description: Faker::Lorem.paragraph, google_plus_likes: rand(10..1000), ratings_all_stars: rand(0..5), ratings_all_count: rand(10..100), installs_min: rand(0..100), installs_max: rand(100..1000000))
    android_app.android_app_snapshots << android_app_snapshot
    android_cat = AndroidAppCategory.all.sample
    android_cat.android_app_snapshots << android_app_snapshot
  end

  puts "creating companies..."
  for i in 1..1500
    if i <= 1000
      Company.create(name: Faker::Company.name, fortune_1000_rank: i, street_address: Faker::Address.street_address, city: Faker::Address.city, zip_code: Faker::Address.zip_code, state: Faker::Address.state_abbr, country: Faker::Address.country)
    else
      Company.create(name: Faker::Company.name, street_address: Faker::Address.street_address, city: Faker::Address.city, zip_code: Faker::Address.zip_code, state: Faker::Address.state_abbr, country: Faker::Address.country)
    end
  end

  puts "creating websites, and linking them to companies, ios apps, and android apps..."
  for i in 1..2000
    site = Website.create(url: Faker::Internet.domain_name, kind: rand(0..1))
    company = Company.all.sample
    ios_app1 = IosApp.all.sample
    ios_app2 = IosApp.all.sample
    android_app1 = AndroidApp.all.sample
    android_app2 = AndroidApp.all.sample
  
    company.websites << site
    ios_app1.websites << site
    ios_app2.websites << site
    android_app1.websites << site
    android_app2.websites << site
    if i % 100 == 0
      puts "#{i/100}/20 of the way done"
    end
  end
end
