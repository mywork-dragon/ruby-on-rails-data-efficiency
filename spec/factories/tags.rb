FactoryGirl.define do
  factory :tag do
    name { Faker::Company.industry }
  end
end
