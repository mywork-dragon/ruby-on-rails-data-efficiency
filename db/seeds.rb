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

puts 'creating App Stores...'
['us', 'jp'].each do |country_code|
  AppStore.create!(country_code: country_code)
end

  puts "creating ios and android apps, and creating snapshots for each..."
  for i in 1..500
    name = Faker::App.name
    ios_app = IosApp.find_or_initialize_by(app_identifier: i)
    ios_app_snapshot = IosAppSnapshot.create(name: name, released: Faker::Time.between(1.year.ago, Time.now), icon_url_350x350: Faker::Avatar.image("#{name}#{i}350", "350x350"), icon_url_175x175: Faker::Avatar.image("#{name}#{i}175"), price: Faker::Commerce.price, size: rand(1000..1000000), version: Faker::App.version, description: Faker::Lorem.paragraph, release_notes: Faker::Lorem.paragraph, ratings_current_stars: rand(0..5), ratings_current_count: rand(0..100), ratings_all_stars: rand(0..5), ratings_all_count: rand(100..500))
    ios_app_snapshot.ratings_per_day_current_release = ios_app_snapshot.ratings_current_count/(Date.tomorrow - ios_app_snapshot.released).to_f
    ios_app.newest_ios_app_snapshot = ios_app_snapshot
    ios_app.app_stores << AppStore.all.sample
    ios_app.save
    ios_app.set_mobile_priority
    ios_app.set_user_base
    
    ios_cat = IosAppCategory.all.sample
    IosAppCategoriesSnapshot.create(ios_app_category: ios_cat, ios_app_snapshot: ios_app_snapshot, kind: IosAppCategoriesSnapshot.kinds.values.sample)
  end
  
  500.times do |i|
    name = "com.#{Faker::App.name.downcase}#{i}"  # this will be unique
    
    android_app = AndroidApp.find_or_create_by(app_identifier: name)
    android_app_snapshot = AndroidAppSnapshot.create(name: name, released: Faker::Time.between(1.year.ago, Time.now), icon_url_300x300: Faker::Avatar.image("#{name}#{i}300", "300x300"), price: Faker::Commerce.price + 1, size: rand(1000..1000000), version: Faker::App.version, description: Faker::Lorem.paragraph, downloads_min: 10e3, downloads_max: 100e6, android_app_id: i+1)
    android_app.newest_android_app_snapshot = android_app_snapshot
    android_app.mobile_priority = (0..2).to_a.sample
    android_app.user_base = (0..3).to_a.sample
    android_app.save
    
    android_cat = AndroidAppCategory.all.sample
    AndroidAppCategoriesSnapshot.create(android_app_category: android_cat, android_app_snapshot: android_app_snapshot, kind: AndroidAppCategoriesSnapshot.kinds.values.sample)
  end

  puts "creating companies..."
  for i in 1..500
    if i <= 300
      Company.create(name: Faker::Company.name, fortune_1000_rank: i, street_address: Faker::Address.street_address, city: Faker::Address.city, zip_code: Faker::Address.zip_code, state: Faker::Address.state_abbr, country: Faker::Address.country, funding: rand(0..100000000))
    else
      Company.create(name: Faker::Company.name, street_address: Faker::Address.street_address, city: Faker::Address.city, zip_code: Faker::Address.zip_code, state: Faker::Address.state_abbr, country: Faker::Address.country, funding: rand(0..100000000))
    end
  end

  puts "creating websites, and linking them to companies, ios apps"

  (n = 500).times do |i|
    website = Website.find_or_create_by(url: Faker::Internet.domain_name, kind: :primary)
    ios_app = IosApp.all.sample
    ios_app = IosApp.includes(websites: :company).where(id: ios_app.id).first
    company = ios_app.get_company.blank? ? Company.all.sample : ios_app.get_company
    company.websites << website
    ios_app.websites << website    
    if i % 100 == 0
      puts "#{i + 1} out of #{n}"
    end
  end
  
  puts "creating websites, and linking them to companies, android apps"
  
  (n = 500).times do |i|
    website = Website.find_or_create_by(url: Faker::Internet.domain_name, kind: :primary)
    android_app = AndroidApp.all.sample
    android_app = AndroidApp.includes(websites: :company).where(id: android_app.id).first
    company = android_app.get_company.blank? ? Company.all.sample : android_app.get_company
    company.websites << website
    android_app.websites << website    
    if i % 100 == 0
      puts "#{i + 1} out of #{n}"
    end
  end

  puts 'creating FB Ads'
  
  100.times do
    ad = IosFbAdAppearance.create
    app = IosApp.all.sample
    app.ios_fb_ad_appearances << ad
  end
  
  puts 'creating Android Ads'
  100.times do
    ad = AndroidFbAdAppearance.create
    app = AndroidApp.all.sample
    app.android_fb_ad_appearances << ad
  end
  
  #Create local IP for Tor
  Proxy.create!(private_ip: '127.0.0.1', active: true)

  GoogleAccount.create!(email: 'stanleyrichardson56@gmail.com', password: 'richardsonpassword!', android_identifier: '3F6351A552536800', blocked: false, flags: 0, last_used: DateTime.now, in_use: false)

end
