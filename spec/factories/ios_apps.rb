FactoryGirl.define do
    factory :ios_app do

      sequence(:app_identifier) { |n| n }
      ios_app_current_snapshots { build_list(:ios_app_current_snapshot, 1, latest: true) }

    end
  end
  