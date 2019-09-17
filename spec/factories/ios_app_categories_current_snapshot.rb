FactoryGirl.define do
  factory :ios_app_categories_current_snapshot do
    ios_app_category { build(:ios_app_category) }
  end
  end
        