def seed_ios_apps
  raise "Unsuficient Ios Devlopers" unless IosDeveloper.count >= 5
  puts 'Seeding Ios Apps'
  disable_logging
  total = 100
  for i in 1..total
    i == total ? puts('.') : print('.')
    name = Faker::App.name + ' ' + Faker::App.name
    developer = IosDeveloper.all.sample
    ios_app = IosApp.find_or_initialize_by(app_identifier: i, ios_developer_id: developer.id)
    ios_app_snapshot = IosAppSnapshot.create(name: name,
                                             released: Faker::Time.between(1.year.ago, Time.now),
                                             icon_url_350x350: Faker::Avatar.image("#{name}#{i}350", "350x350"),
                                             icon_url_175x175: Faker::Avatar.image("#{name}#{i}175"),
                                             price: Faker::Commerce.price,
                                             size: rand(1000..1000000),
                                             version: Faker::App.version,
                                             description: Faker::Lorem.paragraph,
                                             release_notes: Faker::Lorem.paragraph,
                                             ratings_current_stars: rand(0..5),
                                             ratings_current_count: rand(0..100),
                                             ratings_all_stars: rand(0..5),
                                             ratings_all_count: rand(100..500),
                                             seller_url: Faker::Internet.url,
                                             seller: developer.name,
                                             developer_app_store_identifier: Faker::Number.between(1, 50))
    ios_app_snapshot.ratings_per_day_current_release = ios_app_snapshot.ratings_current_count/([1, Date.tomorrow - ios_app_snapshot.released].max).to_f
    ios_app.newest_ios_app_snapshot = ios_app_snapshot
    ios_app.app_stores << AppStore.all.sample
    ios_app.save
    ios_app_snapshot.ios_app = ios_app
    ios_app_snapshot.save
    ios_app.set_user_base

    ios_cat = IosAppCategory.all.sample
    IosAppCategoriesSnapshot.create(ios_app_category: ios_cat, ios_app_snapshot: ios_app_snapshot, kind: IosAppCategoriesSnapshot.kinds.values.sample)
  end
ensure
  puts "Created Ios Apps: #{IosApp.count}"
  enable_logging
end
