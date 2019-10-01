FactoryGirl.define do
    factory :ios_app_current_snapshot do
      after(:create) do |ios_app_current_snapshot, evaluator|
        ios_app_current_snapshot.ios_app_categories_current_snapshots << FactoryGirl.create(:ios_app_categories_current_snapshot, kind: :primary)
        ios_app_current_snapshot.ios_app_categories_current_snapshots << FactoryGirl.create(:ios_app_categories_current_snapshot, kind: :secondary)
      end
    end
  end
        