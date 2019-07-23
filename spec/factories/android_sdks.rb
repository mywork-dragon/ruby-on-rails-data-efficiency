FactoryGirl.define do
  factory :android_sdk do
    sequence(:name)   { |n| "#{Faker::Game.title}-#{n}"  }
    website           { Faker::Internet.url  }
    favicon           { Faker::Internet.url  }
    flagged           false
    open_source       false
    sdk_company       { build(:sdk_company) }
    kind              {AndroidSdk.kinds['native']}

    sequence(:github_repo_identifier) #avoid duplicates
  end
end
