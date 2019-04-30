FactoryGirl.define do
  factory :clearbit_contact do
    given_name  { Faker::Name.first_name }
    family_name { Faker::Name.last_name }
    title       { "Test Title" }
    email       { Faker::Internet.email }
    linkedin    { Faker::Internet.user_name }
    updated_at  { Faker::Time.backward(1, :evening) }

    after(:create) do |contact|
      contact.full_name = "#{contact.given_name} #{contact.family_name}"
    end
  end
end
      