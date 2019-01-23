# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

return unless Rails.env.development?

def create_app_for_developer(developer, app_identifier, category, app_store)
  name = developer.id.to_s + '_' + Faker::App.name + Faker::App.name
  ios_app = IosApp.find_or_initialize_by(app_identifier: app_identifier, ios_developer_id: developer.id)
  ios_app_snapshot = IosAppSnapshot.create(description: Faker::Lorem.paragraph,
                                           developer_app_store_identifier: Faker::Number.between(1, 50),
                                           icon_url_350x350: Faker::Avatar.image("#{name}#{app_identifier}350", "350x350"),
                                           icon_url_175x175: Faker::Avatar.image("#{name}#{app_identifier}175"),
                                           name: name,
                                           price: Faker::Commerce.price,
                                           release_notes: Faker::Lorem.paragraph,
                                           ratings_current_stars: rand(0..5),
                                           ratings_current_count: rand(0..100),
                                           ratings_all_stars: rand(0..5),
                                           ratings_all_count: rand(100..500),
                                           released: Faker::Time.between(1.year.ago, Time.now),
                                           seller_url: Faker::Internet.url,
                                           seller: developer.name,
                                           size: rand(1000..1000000),
                                           version: Faker::App.version)
  ios_app_snapshot.ratings_per_day_current_release = ios_app_snapshot.ratings_current_count/([1, Date.tomorrow - ios_app_snapshot.released].max).to_f
  ios_app.newest_ios_app_snapshot = ios_app_snapshot
  ios_app.app_stores << app_store
  ios_app_snapshot.ios_app = ios_app
  ios_app.save!
  ios_app_snapshot.save
  ios_app.set_user_base

  IosAppCategoriesSnapshot.create(ios_app_category: category, ios_app_snapshot: ios_app_snapshot, kind: IosAppCategoriesSnapshot.kinds.values.sample)
end


def create_app_for_andr_developer(developer, app_identifier, category)
  name = "#{Faker::App.name.downcase}#{app_identifier}"  # this will be unique
  android_app = AndroidApp.find_or_create_by(app_identifier: app_identifier, android_developer_id: developer.id)
  android_app_snapshot = AndroidAppSnapshot.create(android_app_id: android_app.id,
                                                   description: Faker::Lorem.paragraph,
                                                   developer_google_play_identifier: Faker::Number.between(1, 50),
                                                   downloads_max: 100e6,
                                                   downloads_min: 10e3,
                                                   icon_url_300x300: Faker::Avatar.image("#{name}#{app_identifier}300", "300x300"),
                                                   name: name,
                                                   price: Faker::Commerce.price + 1,
                                                   released: Faker::Time.between(1.year.ago, Time.now),
                                                   size: rand(1000..1000000),
                                                   seller_url: Faker::Internet.url,
                                                   seller: developer.name,
                                                   version: Faker::App.version)
  android_app.newest_android_app_snapshot = android_app_snapshot
  # android_app.mobile_priority = (0..2).to_a.sample
  android_app.user_base = (0..3).to_a.sample
  android_app.save!
  android_app_snapshot.android_app = android_app
  android_app_snapshot.save

  AndroidAppCategoriesSnapshot.create(android_app_category: category, android_app_snapshot: android_app_snapshot, kind: AndroidAppCategoriesSnapshot.kinds.values.sample)
end


puts "creating categories..."
categories = %w(Games Lifestyle Shopping Social Entertainment News Education Medical Productivity Music Photography)
ios_categories = categories.map do |cat|
  IosAppCategory.find_or_create_by(name: cat)
end
android_categories = categories.map do |cat|
  AndroidAppCategory.find_or_create_by(name: cat)
end

# Create the proxy container proxy.
MicroProxy.create!(:active=>true, :public_ip => 'proxy', :private_ip =>'proxy', :purpose => :ios)
MicroProxy.create!(:active=>true, :public_ip => 'proxy', :private_ip =>'proxy', :purpose => :general)

puts 'creating App Stores...'
app_stores = [
  AppStore.create!(country_code: "US", display_priority: 1, enabled: true),
  AppStore.create!(country_code: "CN", display_priority: 2, enabled: true),
  AppStore.create!(country_code: "GB", display_priority: 3, enabled: true),
  AppStore.create!(country_code: "JP", display_priority: 4, enabled: true)
]


app_identifier = 0
puts 'creating Developers'
1.times do |j|
  ios_dev = IosDeveloper.create(name: Faker::Company.name)
  rand(1..2).times do |i|
    app_identifier += 1
    create_app_for_developer(ios_dev, app_identifier, ios_categories.sample, app_stores.sample)
  end
end

1.times do |j|
  android_dev = AndroidDeveloper.create(name: Faker::Company.name)
  rand(1..2).times do  |i|
    app_identifier += 1
    create_app_for_andr_developer(android_dev, app_identifier, android_categories.sample)
  end
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
    begin
      website = Website.find_or_create_by(url: Faker::Internet.domain_name + i.to_s, kind: :primary)
      ios_app = IosApp.all.sample
      ios_app = IosApp.includes(websites: :company).where(id: ios_app.id).first
      company = ios_app.get_company.blank? ? Company.all.sample : ios_app.get_company
      company.websites << website
      ios_app.websites << website
      if i % 100 == 0
        puts "#{i + 1} out of #{n}"
      end
    rescue
    end
end

puts "creating websites, and linking them to companies, android apps"

(n = 500).times do |i|
  begin
    website = Website.find_or_create_by(url: Faker::Internet.domain_name + i.to_s, kind: :primary)
    android_app = AndroidApp.all.sample
    android_app = AndroidApp.includes(websites: :company).where(id: android_app.id).first
    company = android_app.get_company.blank? ? Company.all.sample : android_app.get_company
    company.websites << website
    android_app.websites << website
    if i % 100 == 0
      puts "#{i + 1} out of #{n}"
    end
  rescue
  end
end

puts 'creating FB Ads'

1000.times do
  app = IosApp.all.sample
  IosFbAd.create(ios_app_id: app.id, date_seen: Faker::Date.between(1.year.ago, Date.today))
end

puts 'creating Android Ads'
1000.times do
  app = AndroidApp.all.sample
  AndroidAd.create(advertised_app_id: app.id, date_seen: Faker::Date.between(1.year.ago, Date.today))
end

puts 'creating Sdks'
100.times do |i|
  IosSdk.create(name: Faker::Company.name + i.to_s, website: Faker::Internet.url, favicon: Faker::Avatar.image, summary: Faker::Company.catch_phrase, kind: 0, open_source: false)
end
100.times do |i|
  AndroidSdk.create(name: Faker::Company.name + i.to_s, website: Faker::Internet.url, favicon: Faker::Avatar.image, summary: Faker::Company.catch_phrase, kind: 0, open_source: false)
end

ios_apps = IosApp.all
ios_sdks = IosSdk.all
android_apps = AndroidApp.all
android_sdks = AndroidSdk.all

puts 'creating Tags and Tag Relationships'
Tag.create(id: 1, name: "Payments")
Tag.create(id: 2, name: "Monetization")
Tag.create(id: 3, name: "Utilities")
Tag.create(id: 4, name: "Networking")
Tag.create(id: 5, name: "UI")
Tag.create(id: 6, name: "Crash Reporting")
Tag.create(id: 7, name: "Backend")
Tag.create(id: 8, name: "Analytics")
Tag.create(id: 9, name: "Social")
Tag.create(id: 10, name: "Media")
Tag.create(id: 11, name: "Game Engine")
Tag.create(id: 48, name: "Major App")
Tag.create(id: 49, name: "Major Publisher")

ios_sdks.each do |sdk|
  TagRelationship.create(tag_id: rand(1..9), taggable_id: sdk.id, taggable_type: "IosSdk")
end
android_sdks.each do |sdk|
  TagRelationship.create(tag_id: rand(1..11), taggable_id: sdk.id, taggable_type: "AndroidSdk")
end

50.times do
  android_app_id = android_apps.sample.id
  TagRelationship.create(tag_id: 48, taggable_id: android_app_id, taggable_type: "AndroidApp")
end

50.times do
  ios_app_id = ios_apps.sample.id
  TagRelationship.create(tag_id: 48, taggable_id: ios_app_id, taggable_type: "IosApp")
end

puts 'creating Activities'
(n = 1000).times do |i|
  ios_app = ios_apps.sample
  ios_sdk = ios_sdks.sample
  Activity.log_activity(:uninstall, Time.now, ios_app, ios_sdk)
   # if i % 100 == 0
   #   puts "#{i + 1} out of #{n}"
   # end
end
(n = 1000).times do |i|
  ios_app = ios_apps.sample
  ios_sdk = ios_sdks.sample
  Activity.log_activity(:install, Time.now, ios_app, ios_sdk)
   # if i % 100 == 0
   #   puts "#{i + 1} out of #{n}"
   # end
end

GoogleAccount.create!(email: 'stanleyrichardson56@gmail.com', password: 'richardsonpassword!', android_identifier: '3F6351A552536800', blocked: false, flags: 0, last_used: DateTime.now, in_use: false)

apk_snapshot = ApkSnapshot.create(android_app_id: 1)

account = Account.create(name: 'MightySignal', can_view_support_desk: true, can_view_ad_spend: true, can_view_sdks: true, can_view_storewide_sdks: true, can_view_exports: true, can_view_ios_live_scan: true, is_admin_account: true)
user = User.create(email: 'ryan@mightysignal.com', account_id: account.id, password: '12345')
user = User.create(email: 'julian@mightysignal.com', account_id: account.id, password: '12345')
user = User.create(email: 'juan@mightysignal.com', account_id: account.id, password: '12345')
FollowRelationship.create(followable_id: 14, followable_type: 'IosSdk', follower_id: 2, follower_type: 'User')
FollowRelationship.create(followable_id: 14, followable_type: 'IosApp', follower_id: 2, follower_type: 'User')
# sdk_com = AndroidSdkCompany.create(name: 'Test Company', website: 'http://test.com/')

# android_app = AndroidApp.find(1)


# AndroidSdkCompaniesAndroidApp.create!(android_sdk_company: sdk_com, android_app: android_app)


# AndroidSdkPackage.create(package_name: 'com.testpackage.activity', android_sdk_company_id: sdk_com.id)

# AndroidSdkPackage.create(package_name: 'com.testpackage.login', android_sdk_company_id: sdk_com.id)

# AndroidSdkPackagePrefix.create(prefix: 'testpackage', android_sdk_company_id: sdk_com.id)
