FactoryGirl.define do
    factory :ios_app_category do
        name { Faker::Company.industry }
    end
  end
  