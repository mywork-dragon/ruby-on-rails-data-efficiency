# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

return unless Rails.env.development?

require_relative 'seed_helpers/seed_ios_developers'
require_relative 'seed_helpers/seed_android_developers'
require_relative 'seed_helpers/seed_ios_apps'
require_relative 'seed_helpers/seed_android_apps'
require_relative 'seed_helpers/seed_categories'
require_relative 'seed_helpers/seed_micro_proxies'
require_relative 'seed_helpers/seed_app_stores'
require_relative 'seed_helpers/seed_websites'
require_relative 'seed_helpers/seed_clearbit_contacts'
require_relative "seed_helpers/seed_fb_ads"
require_relative "seed_helpers/seed_sdks"
require_relative "seed_helpers/seed_tags"
require_relative "seed_helpers/seed_rankings"

ActiveRecord::Base.transaction do
  seed_categories
  seed_micro_proxies
  seed_app_stores
  seed_ios_developers
  seed_ios_apps
  seed_android_developers
  seed_android_apps
  seed_websites
  seed_clearbit_contacts
  seed_fb_ads
  seed_sdks
  seed_tags
  seed_rankings
end

account = Account.create(
  name: 'MightySignal',
  can_view_support_desk: true,
  can_view_ad_spend: true,
  can_view_sdks: true,
  can_view_storewide_sdks: true,
  can_view_exports: true,
  can_view_ios_live_scan: true,
  is_admin_account: true
)
user = User.create(email: 'juanca@mightysignal.com', account_id: account.id, password: '12345', google_uid: 'xxxxxxxxxxxxxxx')
user = User.create(email: 'julian@mightysignal.com', account_id: account.id, password: '12345', google_uid: 'xxxxxxxxxxxxxxx')
user = User.create(email: 'ryan@mightysignal.com', account_id: account.id, password: '12345', google_uid: 'xxxxxxxxxxxxxxx')


#
# GoogleAccount.create!(email: 'stanleyrichardson56@gmail.com', password: 'richardsonpassword!', android_identifier: '3F6351A552536800', blocked: false, flags: 0, last_used: DateTime.now, in_use: false)
#
# apk_snapshot = ApkSnapshot.create(android_app_id: 1)
#
# FollowRelationship.create(followable_id: 14, followable_type: 'IosSdk', follower_id: 2, follower_type: 'User')
# FollowRelationship.create(followable_id: 14, followable_type: 'IosApp', follower_id: 2, follower_type: 'User')
# sdk_com = AndroidSdkCompany.create(name: 'Test Company', website: 'http://test.com/')

# android_app = AndroidApp.find(1)


# AndroidSdkCompaniesAndroidApp.create!(android_sdk_company: sdk_com, android_app: android_app)


# AndroidSdkPackage.create(package_name: 'com.testpackage.activity', android_sdk_company_id: sdk_com.id)

# AndroidSdkPackage.create(package_name: 'com.testpackage.login', android_sdk_company_id: sdk_com.id)

# AndroidSdkPackagePrefix.create(prefix: 'testpackage', android_sdk_company_id: sdk_com.id)
