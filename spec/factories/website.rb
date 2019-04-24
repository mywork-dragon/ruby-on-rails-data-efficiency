FactoryGirl.define do
  factory :website do
    domain  { Faker::Internet.domain_name }
    url     { Faker::Internet.url }
  end
end
    