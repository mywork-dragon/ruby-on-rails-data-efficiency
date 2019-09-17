FactoryGirl.define do
  factory :android_app_snapshot do
    android_app_categories { build_list(:android_app_category, 1) }
  end
end
      