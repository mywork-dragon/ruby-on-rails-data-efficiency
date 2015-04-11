# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

if Rails.env.development?

  puts "creating ios and android apps..."
  for i in 1..500
    IosApp.find_or_create_by(app_identifier: i)
    AndroidApp.find_or_create_by(app_identifier: "com.company#{i}")
  end

  puts "creating categories..."
  categories = ["Games", "Lifestyle", "Shopping", "Social", "Entertainment", "News", "Education", "Medical", "Productivity", "Music", "Photography"]
  categories.each do |cat|
    IosAppCategory.find_or_create_by(name: cat)
    AndroidAppCategory.find_or_create_by(name: cat)
  end
  
  puts "creating ios and android snapshots..."
  for i in 1..200
    name = Faker::App.name
    ios_snapshot = IosAppSnapshot.create(name: name, released: Faker::Time.between(2.years.ago, Time.now), ios_app_id: IosApp.all.sample.id, icon_url_350x350: Faker::Avatar.image("#{name}#{i}350", "350x350"), icon_url_175x175: Faker::Avatar.image("#{name}#{i}175"))
    ios_cat = IosAppCategory.all.sample
    ios_cat.ios_app_snapshots << ios_snapshot
    android_snapshot = AndroidAppSnapshot.create(name: name, released: Faker::Time.between(2.years.ago, Time.now), android_app_id: AndroidApp.all.sample.id, icon_url_300x300: Faker::Avatar.image("#{name}#{i}300", "300x300"))
    android_cat = AndroidAppCategory.all.sample
    android_cat.android_app_snapshots << android_snapshot
  end

  puts "creating companies..."
  for i in 1..3000
    if i <= 1000
      Company.create(name: Faker::Company.name, fortune_1000_rank: i, street_address: Faker::Address.street_address, city: Faker::Address.city, zip_code: Faker::Address.zip_code, state: Faker::Address.state_abbr, country: Faker::Address.country)
    else
      Company.create(name: Faker::Company.name, street_address: Faker::Address.street_address, city: Faker::Address.city, zip_code: Faker::Address.zip_code, state: Faker::Address.state_abbr, country: Faker::Address.country)
    end
  end

  puts "creating websites, and linking them to companies, ios apps, and android apps..."
  for i in 1..6000
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
  end
end
