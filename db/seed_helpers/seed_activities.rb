def seed_activities
  disable_logging
  puts 'creating Activities'

  ios_apps_ids = IosApp.pluck(:id)
  andr_apps_ids = AndroidApp.pluck(:id)

  ios_sdks_ids = IosSdk.pluck(:id)
  andr_sdks_ids = AndroidSdk.pluck(:id)

  ios_apps_ids.each do |ios_id|
    rand(1..6).times do
      # log_activity prevents logging twice the same activity
      Activity.log_activity(:install, Time.now, IosApp.find(ios_app), IosSdk.find(ios_sdks_ids.sample))
      Activity.log_activity(:uninstall, Time.now, IosApp.find(ios_app), IosSdk.find(ios_sdks_ids.sample))
    end
  end

ensure
  enable_logging
end
