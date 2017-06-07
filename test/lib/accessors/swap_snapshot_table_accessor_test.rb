require 'test_helper'
require 'mocks/mighty_aws_s3_mock'

class SwapSnapshotTableAccessorTest < ActiveSupport::TestCase

  def setup
    @accessor = SwapSnapshotTableAccessor.new
  end

  test 'mobile_priority_value' do
    assert_equal 0, @accessor.mobile_priority_value(:high)
    assert_equal 1, @accessor.mobile_priority_value(:medium)
    assert_equal 2, @accessor.mobile_priority_value(:low)
  end

  test 'column_type' do
    assert_equal :string, @accessor.column_type('name')
    assert_equal :integer, @accessor.column_type('price')
    assert_equal :date, @accessor.column_type('released')
    assert_equal :text, @accessor.column_type('release_notes')
    assert_equal :boolean, @accessor.column_type('has_in_app_purchases')
  end

  test 'user_base_name' do
    assert_equal 'elite', @accessor.user_base_name(0)
    assert_equal 'strong', @accessor.user_base_name(1)
    assert_equal 'moderate', @accessor.user_base_name(2)
    assert_equal 'weak', @accessor.user_base_name(3)
  end

  test 'ios_app_ids_from_store_and_priority' do
    IosAppCurrentSnapshot.create(
      :name=>"Test1", 
      :mobile_priority=>1,
      :app_store_id=>3,
      :ios_app_id=>1,
      :ratings_all_count=>1000)
    IosAppCurrentSnapshot.create(
      :name=>"Test2", 
      :mobile_priority=>1,
      :app_store_id=>1,
      :ios_app_id=>2,
      :ratings_all_count=>5000)
    IosAppCurrentSnapshot.create(
      :name=>"Test3", 
      :mobile_priority=>1,
      :app_store_id=>3,
      :ios_app_id=>3,
      :ratings_all_count=>3000)
    IosAppCurrentSnapshot.create(
      :name=>"Test4", 
      :mobile_priority=>1,
      :app_store_id=>10,
      :ios_app_id=>4,
      :ratings_all_count=>1000)

    result = @accessor.ios_app_ids_from_store_and_priority(3, :medium)
    assert_equal 3, result[0]
    assert_equal 1, result[1]
  end

  test 'ios_app_ids_from_user_base' do
    IosAppCurrentSnapshot.create(
      :name=>"Test1", 
      :mobile_priority=>1,
      :app_store_id=>3,
      :ios_app_id=>1,
      :user_base=>0)
    IosAppCurrentSnapshot.create(
      :name=>"Test2", 
      :mobile_priority=>1,
      :app_store_id=>1,
      :ios_app_id=>2,
      :user_base=>1)
    IosAppCurrentSnapshot.create(
      :name=>"Test3", 
      :mobile_priority=>1,
      :app_store_id=>3,
      :ios_app_id=>3,
      :user_base=>1)

    result = @accessor.ios_app_ids_from_user_base(1)
    assert_includes result, 3
    assert_includes result, 2
    assert_not_includes result, 1
  end

  test 'category_names_from_ios_app' do
    ios_app = IosApp.create(
      :app_id=>1234,
      :app_identifier=>1234)

    snapshot = IosAppCurrentSnapshot.create(
      :name=>"Test1", 
      :mobile_priority=>1,
      :app_store_id=>3,
      :ios_app_id=>ios_app.id,
      :user_base=>0)
    IosAppCurrentSnapshot.create(
      :name=>"Test2", 
      :mobile_priority=>1,
      :app_store_id=>1,
      :ios_app_id=>(ios_app.id + 1),
      :user_base=>1)
    snapshot_3 = IosAppCurrentSnapshot.create(
      :name=>"Test3", 
      :mobile_priority=>1,
      :app_store_id=>2,
      :ios_app_id=>ios_app.id,
      :user_base=>1)

    game_category = IosAppCategory.create(
      :name=>"Game",
      :category_identifier=>1)
    social_category = IosAppCategory.create(
      :name=>"Social",
      :category_identifier=>2)
    IosAppCategory.create(
      :name=>"Finance",
      :category_identifier=>3)

    IosAppCategoriesCurrentSnapshot.create(
      :ios_app_category_id=>game_category.id,
      :ios_app_current_snapshot_id=>snapshot.id,
      :kind=>0)
    IosAppCategoriesCurrentSnapshot.create(
      :ios_app_category_id=>social_category.id,
      :ios_app_current_snapshot_id=>snapshot_3.id,
      :kind=>0)

    result = @accessor.category_names_from_ios_app(ios_app)

    assert_includes result, "Game"
    assert_includes result, "Social"
    assert_not_includes result, "Finance"
  end

  test 'user_base_details_from_ios_app_with_snapshots' do
    ios_app = IosApp.create(
      :app_id=>1234,
      :app_identifier=>1234,
      :user_base=>1)

    app_store = AppStore.create(
      :country_code=>"US",
      :name=>"US_STORE")

    snapshot = IosAppCurrentSnapshot.create(
      :name=>"Test1", 
      :mobile_priority=>1,
      :app_store_id=>app_store.id,
      :ios_app_id=>ios_app.id,
      :user_base=>0)

    result = @accessor.user_base_details_from_ios_app(ios_app)

    assert_equal 1, result.length
    assert_equal "US", result[0][:country_code]
    assert_equal "US_STORE", result[0][:country]
    assert_equal "elite", result[0][:user_base]
  end

  test 'user_base_details_from_ios_app_no_snapshots' do
    ios_app = IosApp.create(
      :app_id=>1234,
      :app_identifier=>1234,
      :user_base=>1)

    app_store = AppStore.create(
      :country_code=>"US",
      :name=>"US_STORE")

    result = @accessor.user_base_details_from_ios_app(ios_app)

    assert_equal 1, result.length
    assert_equal "US", result[0][:country_code]
    assert_equal "United States", result[0][:country]
    assert_equal "strong", result[0][:user_base]
  end

  test 'store_and_rating_details_from_ios_app_with_snapshots' do
    ios_app = IosApp.create(
      :app_id=>1234,
      :app_identifier=>1234,
      :user_base=>1)

    app_store = AppStore.create(
      :country_code=>"US",
      :name=>"US_STORE")

    snapshot = IosAppCurrentSnapshot.create(
      :name=>"Test1", 
      :mobile_priority=>1,
      :app_store_id=>app_store.id,
      :ios_app_id=>ios_app.id,
      :user_base=>0,
      :ratings_all_stars=>3.14,
      :ratings_all_count=>52525)

    result = @accessor.store_and_rating_details_from_ios_app(ios_app)

    assert_equal 1, result.length
    assert_equal "US", result[0][:country_code]
    assert_equal "US_STORE", result[0][:country]
    assert_equal 3.14, result[0][:rating].round(4)
    assert_equal 52525, result[0][:ratings_count]
  end

  test 'store_and_rating_details_from_ios_app_no_snapshots' do
    ios_app = IosApp.create(
      :app_id=>1234,
      :app_identifier=>1234,
      :user_base=>1)

    app_store = AppStore.create(
      :country_code=>"US",
      :name=>"US_STORE")

    result = @accessor.store_and_rating_details_from_ios_app(ios_app)

    assert_equal 1, result.length
    assert_equal "US", result[0][:country_code]
    assert_equal "United States", result[0][:country]
    assert_not result[0][:rating]
    assert_not result[0][:ratings_count]
  end

  test 'first_international_snapshot_with_country_code' do
    ios_app = IosApp.create(
      :app_id=>1234,
      :app_identifier=>1234,
      :user_base=>1)

    unique_store = AppStore.create(
      :country_code=>ios_app.id, # hack to get unique country code
      :name=>"US_STORE")

    jp_app_store = AppStore.create(
      :country_code=>"JP",
      :name=>"JAPAN")

    us_snapshot = IosAppCurrentSnapshot.create(
      :name=>"Test1", 
      :mobile_priority=>1,
      :app_store_id=>unique_store.id,
      :ios_app_id=>ios_app.id,
      :user_base=>0)

    jp_snapshot = IosAppCurrentSnapshot.create(
      :name=>"Test2", 
      :mobile_priority=>1,
      :app_store_id=>jp_app_store.id,
      :ios_app_id=>ios_app.id,
      :user_base=>0)

    result = @accessor.first_international_snapshot_hash_from_ios_app(ios_app, country_code: ios_app.id)

    assert_equal Hash, result.class
    assert_equal "Test1", result["name"]
    assert_equal "medium", result["mobile_priority"]
    assert_equal unique_store.id, result["app_store_id"]
    assert_equal ios_app.id, result["ios_app_id"]
    assert_equal "elite", result["user_base"]
  end

  test 'first_international_snapshot_with_user_base' do
    ios_app = IosApp.create(
      :app_id=>1234,
      :app_identifier=>1234,
      :user_base=>1)

    us_store = AppStore.create(
      :country_code=>"US",
      :name=>"US_STORE")

    jp_app_store = AppStore.create(
      :country_code=>"JP",
      :name=>"JAPAN")

    us_snapshot = IosAppCurrentSnapshot.create(
      :name=>"Test1", 
      :mobile_priority=>1,
      :app_store_id=>us_store.id,
      :ios_app_id=>ios_app.id,
      :user_base=>0)

    jp_snapshot = IosAppCurrentSnapshot.create(
      :name=>"Test2", 
      :mobile_priority=>1,
      :app_store_id=>jp_app_store.id,
      :ios_app_id=>ios_app.id,
      :user_base=>2)

    result = @accessor.first_international_snapshot_hash_from_ios_app(ios_app, user_bases: [:moderate])

    assert_equal Hash, result.class
    assert_equal "Test2", result["name"]
    assert_equal "medium", result["mobile_priority"]
    assert_equal jp_app_store.id, result["app_store_id"]
    assert_equal ios_app.id, result["ios_app_id"]
    assert_equal "moderate", result["user_base"]
  end

  test 'first_international_snapshot_with_country_code_and_user_base' do
    ios_app = IosApp.create(
      :app_id=>1234,
      :app_identifier=>1234,
      :user_base=>1)

    unique_store = AppStore.create(
      :country_code=>ios_app.id, # hack to get unique country code
      :name=>"US_STORE")

    jp_app_store = AppStore.create(
      :country_code=>"JP",
      :name=>"JAPAN")

    us_snapshot = IosAppCurrentSnapshot.create(
      :name=>"Test1", 
      :mobile_priority=>1,
      :app_store_id=>unique_store.id,
      :ios_app_id=>ios_app.id,
      :user_base=>1)

    jp_snapshot = IosAppCurrentSnapshot.create(
      :name=>"Test3", 
      :mobile_priority=>1,
      :app_store_id=>jp_app_store.id,
      :ios_app_id=>ios_app.id,
      :user_base=>0)

    result = @accessor.first_international_snapshot_hash_from_ios_app(ios_app, country_code: ios_app.id, user_bases: [:elite, :strong])

    assert_equal Hash, result.class
    assert_equal "Test1", result["name"]
    assert_equal "medium", result["mobile_priority"]
    assert_equal unique_store.id, result["app_store_id"]
    assert_equal ios_app.id, result["ios_app_id"]
    assert_equal "strong", result["user_base"]
  end

  test 'first_international_snapshot_with_user_base_order' do
    ios_app = IosApp.create(
      :app_id=>1234,
      :app_identifier=>1234,
      :user_base=>1)

    us_store = AppStore.create(
      :country_code=>"US",
      :name=>"US_STORE",
      :display_priority=>2)

    jp_app_store = AppStore.create(
      :country_code=>"JP",
      :name=>"JAPAN",
      :display_priority=>1)

    us_snapshot = IosAppCurrentSnapshot.create(
      :name=>"Test1", 
      :mobile_priority=>1,
      :app_store_id=>us_store.id,
      :ios_app_id=>ios_app.id,
      :user_base=>1)

    jp_snapshot = IosAppCurrentSnapshot.create(
      :name=>"Test2", 
      :mobile_priority=>1,
      :app_store_id=>jp_app_store.id,
      :ios_app_id=>ios_app.id,
      :user_base=>1)

    result = @accessor.first_international_snapshot_hash_from_ios_app(ios_app, user_bases: [:strong])

    assert_equal Hash, result.class
    assert_equal "Test2", result["name"]
    assert_equal "medium", result["mobile_priority"]
    assert_equal jp_app_store.id, result["app_store_id"]
    assert_equal ios_app.id, result["ios_app_id"]
    assert_equal "strong", result["user_base"]
  end

  test 'recently_released_ios_app_ids' do
    now = Date.today

    ios_app_1 = IosApp.create(
      :app_id=>1234,
      :app_identifier=>1234,
      :released=>now - 10)
    ios_app_2 = IosApp.create(
      :app_id=>1235,
      :app_identifier=>1235,
      :released=>now - 1)
    ios_app_3 = IosApp.create(
      :app_id=>1236,
      :app_identifier=>1236,
      :released=>now - 1)

    ios_snapshot_1 = IosAppCurrentSnapshot.create(
      :name=>"Test1",
      :app_store_id=>1,
      :ios_app_id=>ios_app_1.id,
      :ratings_all_count=>10)
    ios_snapshot_2 = IosAppCurrentSnapshot.create(
      :name=>"Test2", 
      :app_store_id=>1,
      :ios_app_id=>ios_app_2.id,
      :ratings_all_count=>1) 
    ios_snapshot_3 = IosAppCurrentSnapshot.create(
      :name=>"Test3",
      :app_store_id=>2,
      :ios_app_id=>ios_app_2.id,
      :ratings_all_count=>10) 
    ios_snapshot_4 = IosAppCurrentSnapshot.create(
      :name=>"Test4",
      :app_store_id=>1,
      :ios_app_id=>ios_app_3.id,
      :ratings_all_count=>10) 

    result = @accessor.recently_released_ios_app_ids(now - 5, 5, 1)

    assert_equal 1, result.length
    assert_equal ios_app_3.id, result[0]
  end

  test 'recently_updated_snapshot_ids_lookback_time_defaults_to_two_weeks' do
    ios_app_1 = IosApp.create(
      :app_id=>1234,
      :app_identifier=>1234)
    ios_app_2 = IosApp.create(
      :app_id=>1235,
      :app_identifier=>1235)

    ios_snapshot_1 = IosAppCurrentSnapshot.create(
      :name=>"Test1",
      :app_store_id=>1,
      :ios_app_id=>ios_app_1.id,
      :user_base=>0,
      :released=>10.days.ago,
      :ratings_all_count=>10)
    ios_snapshot_2 = IosAppCurrentSnapshot.create(
      :name=>"Test2",
      :app_store_id=>1,
      :ios_app_id=>ios_app_2.id,
      :user_base=>0,
      :released=>20.days.ago,
      :ratings_all_count=>10)

    result = @accessor.recently_updated_snapshot_ids(limit: 10, ratings_min: 5, app_store_id: 1)
    
    assert_equal 1, result.length
    assert_equal ios_app_1.id, result[0]
  end

  test 'recently_updated_snapshot_ids_lookback_time_ratings_min' do
    ios_app_1 = IosApp.create(
      :app_id=>1234,
      :app_identifier=>1234)
    ios_app_2 = IosApp.create(
      :app_id=>1235,
      :app_identifier=>1235)

    ios_snapshot_1 = IosAppCurrentSnapshot.create(
      :name=>"Test1",
      :app_store_id=>1,
      :ios_app_id=>ios_app_1.id,
      :user_base=>0,
      :released=>5.days.ago,
      :ratings_all_count=>3)
    ios_snapshot_2 = IosAppCurrentSnapshot.create(
      :name=>"Test2",
      :app_store_id=>1,
      :ios_app_id=>ios_app_2.id,
      :user_base=>0,
      :released=>5.days.ago,
      :ratings_all_count=>7)

    result = @accessor.recently_updated_snapshot_ids(limit: 10, ratings_min: 5, app_store_id: 1, lookback_time: 2.weeks.ago)
    
    assert_equal 1, result.length
    assert_equal ios_app_2.id, result[0]
  end

  test 'recently_updated_snapshot_ids_lookback_time_limit' do
    ios_app_1 = IosApp.create(
      :app_id=>1234,
      :app_identifier=>1234)
    ios_app_2 = IosApp.create(
      :app_id=>1235,
      :app_identifier=>1235)
    ios_app_3 = IosApp.create(
      :app_id=>1236,
      :app_identifier=>1236)

    ios_snapshot_1 = IosAppCurrentSnapshot.create(
      :name=>"Test1",
      :app_store_id=>1,
      :ios_app_id=>ios_app_1.id,
      :user_base=>0,
      :released=>5.days.ago,
      :ratings_all_count=>8)
    ios_snapshot_2 = IosAppCurrentSnapshot.create(
      :name=>"Test2",
      :app_store_id=>1,
      :ios_app_id=>ios_app_2.id,
      :user_base=>0,
      :released=>5.days.ago,
      :ratings_all_count=>9)
    ios_snapshot_3 = IosAppCurrentSnapshot.create(
      :name=>"Test3",
      :app_store_id=>1,
      :ios_app_id=>ios_app_3.id,
      :user_base=>0,
      :released=>5.days.ago,
      :ratings_all_count=>7)

    result = @accessor.recently_updated_snapshot_ids(limit: 2, ratings_min: 5, app_store_id: 1, lookback_time: 2.weeks.ago)
    
    assert_equal 2, result.length
    assert_equal ios_app_2.id, result[0]
    assert_equal ios_app_1.id, result[1]
  end

  test 'recently_updated_snapshot_ids_lookback_time_app_store' do
    ios_app_1 = IosApp.create(
      :app_id=>1234,
      :app_identifier=>1234)
    ios_app_2 = IosApp.create(
      :app_id=>1235,
      :app_identifier=>1235)

    ios_snapshot_1 = IosAppCurrentSnapshot.create(
      :name=>"Test1",
      :app_store_id=>1,
      :ios_app_id=>ios_app_1.id,
      :user_base=>0,
      :released=>5.days.ago,
      :ratings_all_count=>3)
    ios_snapshot_2 = IosAppCurrentSnapshot.create(
      :name=>"Test2",
      :app_store_id=>2,
      :ios_app_id=>ios_app_2.id,
      :user_base=>0,
      :released=>5.days.ago,
      :ratings_all_count=>7)

    result = @accessor.recently_updated_snapshot_ids(limit: 10, ratings_min: 5, app_store_id: 2, lookback_time: 2.weeks.ago)
    
    assert_equal 1, result.length
    assert_equal ios_app_2.id, result[0]
  end

  test 'recently_updated_snapshot_ids_lookback_time_lookback_time' do
    ios_app_1 = IosApp.create(
      :app_id=>1234,
      :app_identifier=>1234)
    ios_app_2 = IosApp.create(
      :app_id=>1235,
      :app_identifier=>1235)

    ios_snapshot_1 = IosAppCurrentSnapshot.create(
      :name=>"Test1",
      :app_store_id=>1,
      :ios_app_id=>ios_app_1.id,
      :user_base=>0,
      :released=>2.days.ago,
      :ratings_all_count=>3)
    ios_snapshot_2 = IosAppCurrentSnapshot.create(
      :name=>"Test2",
      :app_store_id=>1,
      :ios_app_id=>ios_app_2.id,
      :user_base=>0,
      :released=>10.days.ago,
      :ratings_all_count=>7)

    result = @accessor.recently_updated_snapshot_ids(limit: 10, ratings_min: 1, app_store_id: 1, lookback_time: 5.days.ago)
    
    assert_equal 1, result.length
    assert_equal ios_app_1.id, result[0]
  end

  test 'user_base_values_from_ios_app' do
    us_store = AppStore.create(
      :country_code=>"US",
      :name=>"US_STORE",
      :display_priority=>2,
      :enabled=>true)

    jp_store = AppStore.create(
      :country_code=>"JP",
      :name=>"JP_STORE",
      :display_priority=>1,
      :enabled=>true)

    ios_app_1 = IosApp.create(
      :app_id=>1234,
      :app_identifier=>1234)

    ios_snapshot_1 = IosAppCurrentSnapshot.create(
      :name=>"Test1",
      :app_store_id=>us_store.id,
      :ios_app_id=>ios_app_1.id,
      :user_base=>0)

    ios_snapshot_2 = IosAppCurrentSnapshot.create(
      :name=>"Test2",
      :app_store_id=>jp_store.id,
      :ios_app_id=>ios_app_1.id,
      :user_base=>1)

    result = @accessor.user_base_values_from_ios_app(ios_app_1)

    assert_equal 2, result.length
    assert_equal 1, result[0]
    assert_equal 0, result[1]
  end

  test 'user_base_values_from_ios_app_excludes_disabled' do
    us_store = AppStore.create(
      :country_code=>"US",
      :name=>"US_STORE",
      :display_priority=>2,
      :enabled=>true)

    jp_store = AppStore.create(
      :country_code=>"JP",
      :name=>"JP_STORE",
      :display_priority=>2,
      :enabled=>false)

    ios_app_1 = IosApp.create(
      :app_id=>1234,
      :app_identifier=>1234)

    ios_snapshot_1 = IosAppCurrentSnapshot.create(
      :name=>"Test1",
      :app_store_id=>us_store.id,
      :ios_app_id=>ios_app_1.id,
      :user_base=>0)

    ios_snapshot_2 = IosAppCurrentSnapshot.create(
      :name=>"Test2",
      :app_store_id=>jp_store.id,
      :ios_app_id=>ios_app_1.id,
      :user_base=>1)

    result = @accessor.user_base_values_from_ios_app(ios_app_1)

    assert_equal 1, result.length
    assert_equal 0, result[0]
  end

  test 'app_store_details_from_ios_apps' do
    ios_app_1 = IosApp.create(
      :app_id=>1234,
      :app_identifier=>1234)

    ios_app_2 = IosApp.create(
      :app_id=>1235,
      :app_identifier=>1235)

    us_store = AppStore.create(
      :country_code=>"US",
      :name=>"US_STORE",
      :display_priority=>2,
      :enabled=>true)

    jp_store = AppStore.create(
      :country_code=>"JP",
      :name=>"JP_STORE",
      :display_priority=>1,
      :enabled=>true)

    ios_snapshot_1 = IosAppCurrentSnapshot.create(
      :name=>"Test1",
      :app_store_id=>us_store.id,
      :ios_app_id=>ios_app_1.id,
      :user_base=>0)

    ios_snapshot_2 = IosAppCurrentSnapshot.create(
      :name=>"Test2",
      :app_store_id=>jp_store.id,
      :ios_app_id=>ios_app_1.id,
      :user_base=>1)

    ios_snapshot_3 = IosAppCurrentSnapshot.create(
      :name=>"Test3",
      :app_store_id=>us_store.id,
      :ios_app_id=>ios_app_2.id,
      :user_base=>3)

    both_apps_result = @accessor.app_store_details_from_ios_apps([ios_app_1, ios_app_2])

    assert_equal 3, both_apps_result.length
    assert_equal "Test2", both_apps_result[0][1]
    assert_equal "Test1", both_apps_result[1][1]
    assert_equal "Test3", both_apps_result[2][1]
  end

  test 'category_details_from_ios_apps' do
    ios_app = IosApp.create(
      :app_id=>1234,
      :app_identifier=>1234)
    ios_app_2 = IosApp.create(
      :app_id=>1235,
      :app_identifier=>1235)

    snapshot = IosAppCurrentSnapshot.create(
      :name=>"Test1", 
      :mobile_priority=>1,
      :app_store_id=>3,
      :ios_app_id=>ios_app.id,
      :user_base=>0)
    snapshot_2 = IosAppCurrentSnapshot.create(
      :name=>"Test2", 
      :mobile_priority=>1,
      :app_store_id=>1,
      :ios_app_id=>ios_app_2.id,
      :user_base=>1)
    snapshot_3 = IosAppCurrentSnapshot.create(
      :name=>"Test3", 
      :mobile_priority=>1,
      :app_store_id=>2,
      :ios_app_id=>ios_app.id,
      :user_base=>1)

    game_category = IosAppCategory.create(
      :name=>"Game",
      :category_identifier=>1)
    social_category = IosAppCategory.create(
      :name=>"Social",
      :category_identifier=>2)
    finance_category = IosAppCategory.create(
      :name=>"Finance",
      :category_identifier=>3)

    IosAppCategoriesCurrentSnapshot.create(
      :ios_app_category_id=>game_category.id,
      :ios_app_current_snapshot_id=>snapshot.id,
      :kind=>0)
    IosAppCategoriesCurrentSnapshot.create(
      :ios_app_category_id=>finance_category.id,
      :ios_app_current_snapshot_id=>snapshot_2.id,
      :kind=>0)
    IosAppCategoriesCurrentSnapshot.create(
      :ios_app_category_id=>social_category.id,
      :ios_app_current_snapshot_id=>snapshot_3.id,
      :kind=>0)

    result = @accessor.category_details_from_ios_apps([ios_app, ios_app_2])

    assert_equal 3, result.length
    assert_includes result, [ios_app.id, "Game"]
    assert_includes result, [ios_app.id, "Social"]
    assert_includes result, [ios_app_2.id, "Finance"]
  end
end
