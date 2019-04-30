FactoryGirl.define do
    factory :domain_datum do
      domain  { Faker::Internet.domain_name }
      name  { Faker::Internet.domain_name }

      after(:create) do |domain_datum|
        domain_datum.clearbit_contacts << FactoryGirl.create(:clearbit_contact)
      end

    end
  end
      