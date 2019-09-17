FactoryGirl.define do
  factory :android_app do

    sequence(:app_identifier) { |n| n }

    newest_android_app_snapshot { build(:android_app_snapshot)  }
  end
end
