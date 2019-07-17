FactoryGirl.define do
  factory :apk_snapshot do
    android_sdks { build_list(:android_sdk, 1) }
    trait :scan_success do
      scan_status ApkSnapshot.scan_statuses['scan_success']
    end
  end
end
