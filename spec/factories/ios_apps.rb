FactoryGirl.define do
  factory :ios_app do
    newest_ios_app_snapshot     { build(:ios_app_snapshot)  }
    newest_ipa_snapshot         { build(:ipa_snapshot)          }
    ipa_snapshots               { build_list(:ipa_snapshot, 2, :scan_success)  }
    sequence(:app_identifier) { |n| n }
    ios_app_current_snapshots { build_list(:ios_app_current_snapshot, 1, latest: true) }
  end
end
