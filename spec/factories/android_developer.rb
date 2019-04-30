FactoryGirl.define do
  factory :android_developer do
    name  { Faker::Name.name }

    transient do
      domain  Faker::Internet.domain_name
    end

    after(:create) do |android_developer, evaluator|
      android_developer.websites << FactoryGirl.create(:website, domain: evaluator.domain, url: "www.test.#{evaluator.domain}")
      FactoryGirl.create(:domain_datum, domain: evaluator.domain, name: evaluator.domain)
    end
  end     
end
  