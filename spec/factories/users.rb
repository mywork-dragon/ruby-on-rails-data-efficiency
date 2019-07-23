FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "#{Faker::Internet.username(8)}-#{n}@spec.com" }
    password { Faker::Internet.password(8) }

    account { build(:account) }
  end
end
