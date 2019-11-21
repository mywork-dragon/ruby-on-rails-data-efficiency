FactoryGirl.define do
  factory :android_app_snapshot do
    name 'Tic Tac Toe'
    ratings_all_stars 3.59
    ratings_all_count 100
    android_app_categories { build_list(:android_app_category, 1) }
  end
end
