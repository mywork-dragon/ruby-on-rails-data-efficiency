FactoryGirl.define do
  factory :android_app do

    newest_android_app_snapshot { build(:android_app_snapshot)  }
    newest_apk_snapshot         { build(:apk_snapshot)          }
    apk_snapshots               { build_list(:apk_snapshot, 2, :scan_success)  }

    sequence(:app_identifier) { |n| n }

    newest_android_app_snapshot { build(:android_app_snapshot)  }
  end
end
