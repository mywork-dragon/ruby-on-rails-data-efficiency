FactoryGirl.define do
  factory :ipa_snapshot do
    ios_sdks { build_list(:ios_sdk, 1) }
    trait :scan_success do
      scan_status ApkSnapshot.scan_statuses['scan_success']
    end
    trait :scan_failure do
      scan_status ApkSnapshot.scan_statuses['scan_failure']
    end
  end
end
