FactoryGirl.define do
    factory :ios_app_categories_current_snapshot do
      after(:create) do |ios_app_categories_current_snapshot, evaluator|
        ios_app_categories_current_snapshot.ios_app_category = FactoryGirl.create(:ios_app_category)
      end
    end
  end
        