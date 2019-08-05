FactoryGirl.define do
    factory :ios_app do

      sequence(:app_identifier) { |n| n }
      
      after(:create) do |ios_app, evaluator|
        ios_app.ios_app_current_snapshots << FactoryGirl.create(:ios_app_current_snapshot, latest: true)
      end
    end
  end
  