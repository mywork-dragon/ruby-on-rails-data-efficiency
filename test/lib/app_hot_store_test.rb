require 'test_helper'
require 'mocks/redis_mock'
require 'lib/hotstore/hot_store_schema_test_base'

class AppHotStoreTest < ::HotStoreSchemaTestBase

  def setup
    @redis = RedisMock.new
    @hot_store = AppHotStore.new(redis_store: @redis)

    @date1 = Time.now
    @date2 = Time.now
    @date3 = 2.days.ago

    @app = AndroidApp.create!(
      app_identifier: 'com.mightysignal.osman',
      user_base: :elite
    )

    @snapshot = AndroidAppSnapshot.create!(
      name: 'Osman',
      description: 'my app',
      price: 12,
      size: 1337,
      updated: @date1,
      seller_url: 'osman-the-man.com',
      version: "osman1.0",
      released: @date2,
      android_app_id: @app.id,
      top_dev: true,
      in_app_purchases: false,
      required_android_version: "osman2.0",
      content_rating: "osman rated m for mature",
      seller: "osman seller of goods",
      ratings_all_stars: 1.23,
      ratings_all_count: 123,
      status: 1,
      android_app_snapshot_job_id: 2,
      in_app_purchase_min: 1,
      in_app_purchase_max: 10,
      downloads_min: 123,
      downloads_max: 123123123,
      icon_url_300x300: "osman the selfie icon",
      developer_google_play_identifier: "osman the google play dev",
      apk_access_forbidden: false,
      created_at: @date1,
      updated_at: @date2
    )

    @snapshot_2 = AndroidAppSnapshot.create!(
      name: 'Osman',
      description: 'my app',
      price: 12,
      size: 1337,
      updated: @date1,
      seller_url: 'osman-the-man.com',
      version: "osman0.1",
      released: @date2,
      android_app_id: @app.id,
      top_dev: true,
      in_app_purchases: false,
      required_android_version: "osman2.0",
      content_rating: "osman rated m for mature",
      seller: "osman seller of goods",
      ratings_all_stars: 3.23,
      ratings_all_count: 5555,
      status: 1,
      android_app_snapshot_job_id: 2,
      in_app_purchase_min: 1,
      in_app_purchase_max: 10,
      downloads_min: 123,
      downloads_max: 993123123,
      icon_url_300x300: "osman the selfie icon",
      developer_google_play_identifier: "osman the google play dev",
      apk_access_forbidden: false,
      created_at: @date3,
      updated_at: @date2
    )

    @category = AndroidAppCategory.create!(
      name: "cool kids",
      category_id: "cool kids don't got ids"
    )

    @snapshot.android_app_categories << @category

    @developer = AndroidDeveloper.create!(
      name: "Osman the android developer of oz",
      identifier: "yell",
    )

    @app.update(:android_developer => @developer)

    @website_1 = Website.create!(
      url: "osman.com"
    )

    @website_2 = Website.create!(
      url: "osman2.com"
    )

    @domain_data_1 = DomainDatum.create!(
      domain: "osman1.com",
      street_number: "123",
      street_name: "cookies blvd",
      sub_premise: "what is this field",
      city: "sf",
      postal_code: "12345",
      state: "Cali",
      state_code: "CA",
      country: "USA",
      country_code: "USA",
      lat: 123,
      lng: 456
    )

    @domain_data_2 = DomainDatum.create!(
      domain: "osman2.com",
      street_number: "345",
      street_name: "cookies blvd 2",
      sub_premise: "what is this field 2",
      city: "sf2",
      postal_code: "12345232",
      state: "Cali2",
      state_code: "CA",
      country: "USA",
      country_code: "USA",
      lat: 876,
      lng: 451
    )

    @website_1.update(:domain_datum => @domain_data_1)
    @website_2.update(:domain_datum => @domain_data_2)
    @developer.websites << @website_1
    @developer.websites << @website_2

    @apk_snapshot = ApkSnapshot.create!(
      scan_status: 1,
      android_app_id: @app.id,
      good_as_of_date: @date1
    )

    @sdk_1 = AndroidSdk.create!(
      name: 'penny eater 1',
      website: 'dawn-the-penny-eater.com',
      kind: :native
    )
    @sdk_2 = AndroidSdk.create!(
      name: 'penny eater 2',
      website: 'marco-the-penny-eater.com',
      kind: :native
    )

    tag = Tag.create!(name: "copper is bad")

    @sdk_1.tags << tag
    @sdk_2.tags << tag

    @apk_snapshot_1 = ApkSnapshot.create!(
      android_app_id: @app.id,
      scan_status: 1,
      good_as_of_date: 2.days.ago
    )

    @apk_snapshot_2 = ApkSnapshot.create!(
      android_app_id: @app.id,
      scan_status: 1,
      good_as_of_date: 1.days.ago
    )

    @apk_snapshot_1.android_sdks << @sdk_1
    @apk_snapshot_2.android_sdks << @sdk_2

    @app.apk_snapshots << @apk_snapshot_1
    @app.apk_snapshots << @apk_snapshot_2

    @app.update(:newest_apk_snapshot => @apk_snapshot_2)
    @app.update!(newest_android_app_snapshot: @snapshot)
  end

  test 'writes android attributes with correct schema and values' do
    @hot_store.write("android", [@app.id])
    stored_attributes = @hot_store.read("android", @app.id)

    # Manually fill in last stop dates, since test will fail if they are nil
    stored_attributes["ratings_history"][stored_attributes["ratings_history"].length - 1]["stop_date"] = ""
    stored_attributes["downloads_history"][stored_attributes["downloads_history"].length - 1]["stop_date"] = ""
    stored_attributes["sdk_activity"].find{ |a| a["id"] == @sdk_2.id }["first_unseen_date"]= ""

    validate(app_schema, stored_attributes)

    assert_equal stored_attributes["app_identifier"], "com.mightysignal.osman"
    assert_equal stored_attributes["current_version"], "osman1.0"
    assert_equal stored_attributes["user_base"], "elite"
    assert_equal stored_attributes["google_play_id"], "com.mightysignal.osman"
    assert_equal stored_attributes["id"], @app.id
    assert_equal stored_attributes["taken_down"], false
    assert_equal stored_attributes["name"], "Osman"
    assert_equal stored_attributes["price"], 12
    assert_equal stored_attributes["seller_url"], "osman-the-man.com"
    assert_equal stored_attributes["description"], "my app"
    assert_equal stored_attributes["in_app_purchases"], false
    assert_equal stored_attributes["required_android_version"], "osman2.0"
    assert_equal stored_attributes["content_rating"], "osman rated m for mature"
    assert_equal stored_attributes["seller"], "osman seller of goods"
    assert_equal stored_attributes["in_app_purchase_min"], 1
    assert_equal stored_attributes["in_app_purchase_max"], 10
    assert_equal stored_attributes["downloads_min"], 123
    assert_equal stored_attributes["downloads_max"], 123123123
    assert_equal stored_attributes["developer_google_play_identifier"], "osman the google play dev"

    assert_equal @redis.sismember("app_keys", "app:android:#{@app.id}"), "1"
  end

end
