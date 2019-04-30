FactoryGirl.define do
    factory :ios_developer do
      name  { Faker::Name.name }
  
      transient do
        domain  Faker::Internet.domain_name
      end
  
      after(:create) do |ios_developer, evaluator|
        ios_developer.websites << FactoryGirl.create(:website, domain: evaluator.domain, url: "www.test.#{evaluator.domain}")
        FactoryGirl.create(:domain_datum, domain: evaluator.domain, name: evaluator.domain)
      end
    end     
  end
    