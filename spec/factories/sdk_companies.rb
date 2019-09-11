FactoryGirl.define do
  factory :sdk_company do
    sequence(:name)      { |n| "#{n}#{Faker::Company.name} #{Faker::Company.suffix}" }
    favicon   'https://www.favicon.cc/?action=icon&file_id=249817'
    flagged   false
    sequence(:website)   { |n| "#{Faker::Internet.domain_name} - #{n}" }
  end
end
