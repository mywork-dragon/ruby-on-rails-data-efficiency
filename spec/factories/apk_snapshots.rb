FactoryGirl.define do
  factory :apk_snapshot do
    android_sdks { build_list(:android_sdk, 1) }
    trait :scan_success do
      scan_status ApkSnapshot.scan_statuses['scan_success']
    end
    trait :scan_failure do
      scan_status ApkSnapshot.scan_statuses['scan_failure']
    end
    trait :version_code_incr do
      sequence(:version_code)
    end
  end
end
