FactoryGirl.define do
  factory :apk_snapshot_job do
    job_type :test
    trait :live { job_type :live }
    trait :mass { job_type :mass }
  end
end
