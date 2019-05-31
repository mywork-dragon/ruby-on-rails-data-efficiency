def seed_app_stores
  puts "creating App Stores"
  disable_logging
  AppStore.create!(country_code: "US", display_priority: 1, enabled: true)
  AppStore.create!(country_code: "CN", display_priority: 2, enabled: true)
  AppStore.create!(country_code: "GB", display_priority: 3, enabled: true)
  AppStore.create!(country_code: "JP", display_priority: 4, enabled: true)
ensure
  puts "Created App Stores: #{AppStore.count}"
  enable_logging
end
