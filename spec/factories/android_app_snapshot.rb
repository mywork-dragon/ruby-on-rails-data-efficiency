FactoryGirl.define do
  factory :android_app_snapshot do
    after(:create) do |android_app_snapshot, evaluator|
      android_app_snapshot.android_app_categories << FactoryGirl.create(:android_app_category)
    end
  end
end
      