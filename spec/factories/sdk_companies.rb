FactoryGirl.define do
  factory :sdk_company do
    name      { Faker::Company.name }
    favicon   'https://www.favicon.cc/?action=icon&file_id=249817'
    flagged   false
    sequence(:website)   { |n| "#{Faker::Internet.domain_name} - #{n}" }
  end
end
