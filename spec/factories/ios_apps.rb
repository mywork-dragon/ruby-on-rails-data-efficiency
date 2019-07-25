FactoryGirl.define do
  factory :ios_app do
    newest_ios_app_snapshot     { build(:ios_app_snapshot)  }
    newest_ipa_snapshot         { build(:ipa_snapshot)          }
    ipa_snapshots               { build_list(:ipa_snapshot, 2, :scan_success)  }
  end
end
