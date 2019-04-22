FactoryGirl.define do
  factory :android_developer do

    factory :android_developer_with_valid_websites do
      transient do
        valid_websites_count 1
      end

      after(:create) do |android_developer, evaluator|
        create_list(:valid_websites, evaluator.valid_websites_count, android_developer: android_developer)
      end
    end

  end     
end
  