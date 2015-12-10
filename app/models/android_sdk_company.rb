class AndroidSdkCompany < ActiveRecord::Base

	has_many :android_sdk_packages
	has_many :android_sdk_package_prefixes

	has_many :android_sdk_companies_apk_snapshots
  has_many :apk_snapshots, through: :android_sdk_companies_apk_snapshots

  has_many :android_sdk_companies_android_apps
  has_many :android_apps, through: :android_sdk_companies_android_apps

  def get_current_apps(count_only: false, filtered_count_only: false)

    li "############### 1 - Entered Method ###############"

    # get all successful snapshots that have the sdk
    apk_snapshots = self.apk_snapshots

    li "############### 2 - Apk Snapshots Grabbed ###############"

    result_apps = []

    apk_snapshots.each do |apk_snapshot|
      android_app = AndroidApp.find(apk_snapshot.android_app_id)

      # If latest snapshot, add respective app to results
      if apk_snapshot.id == android_app.newest_apk_snapshot_id
        result_apps << android_app
      end
    end

    li "############### 3 - Newest Snapshots Found ###############"

    if count_only
      result = result_apps.length
    elsif filtered_count_only
      app_ids = []
      result_apps.each do |app|
        app_ids << app.id
      end

      apps_count = AndroidApp.instance_eval("self.includes(:ios_fb_ad_appearances, newest_ios_app_snapshot: :ios_app_categories, websites: :company).joins(:newest_ios_app_snapshot).where('ios_app_snapshots.name IS NOT null').joins(websites: :company).where('ios_apps.id IN (?)', #{app_ids}).group('ios_apps.id').count.length")

      result = apps_count
    else
      result = result_apps
    end

    result
  end

end
