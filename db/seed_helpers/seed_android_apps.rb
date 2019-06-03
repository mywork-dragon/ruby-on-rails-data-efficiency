def seed_android_apps
  puts 'Seeding Android apps'
  total = 100
  disable_logging
  for i in 1..total
    i == total ? puts('.') : print('.')
    name = "com.#{Faker::App.name.downcase}#{i}"  # this will be unique
    developer = AndroidDeveloper.all.sample
    android_app = AndroidApp.find_or_create_by(app_identifier: name, android_developer_id: developer.id)
    android_app_snapshot = AndroidAppSnapshot.create(name: name,
                                                     released: Faker::Time.between(1.year.ago, Time.now),
                                                     icon_url_300x300: Faker::Avatar.image("#{name}#{i}300", "300x300"),
                                                     price: Faker::Commerce.price + 1,
                                                     size: rand(1000..1000000),
                                                     version: Faker::App.version,
                                                     description: Faker::Lorem.paragraph,
                                                     downloads_min: 10e3,
                                                     downloads_max: 100e6,
                                                     android_app_id: i+1,
                                                     seller_url: Faker::Internet.url,
                                                     seller: developer.name,
                                                     developer_google_play_identifier: Faker::Number.between(1, 50))
    android_app.newest_android_app_snapshot = android_app_snapshot
    # android_app.mobile_priority = (0..2).to_a.sample
    android_app.user_base = (0..3).to_a.sample
    android_app.save
    android_app_snapshot.android_app = android_app
    android_app_snapshot.save

    android_cat = AndroidAppCategory.all.sample
    AndroidAppCategoriesSnapshot.create(android_app_category: android_cat, android_app_snapshot: android_app_snapshot, kind: AndroidAppCategoriesSnapshot.kinds.values.sample)
  end
ensure
  enable_logging
end
