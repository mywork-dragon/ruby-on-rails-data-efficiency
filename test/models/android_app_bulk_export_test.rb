require 'test_helper'
require 'mocks/elasticsearch_mock'

class AndroidAppBulkExportTest < ActiveSupport::TestCase

  def setup
    @date1 = Time.now
    @date2 = Time.now

    @app = AndroidApp.create!(
      app_identifier: 'com.mightysignal.osman',
      user_base: :elite,
      created_at: @date2
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

    @sdk = AndroidSdk.create!(name: 'sup', website: 'hello.com', kind: :native)
    @app.update!(newest_android_app_snapshot: @snapshot)
  end

  test 'single app' do
    result = AndroidApp.bulk_export(ids: [@app.id])[@app.id]

    assert_equal result["app_identifier"], "com.mightysignal.osman"
    assert_equal result["user_base"], "elite"
    assert_equal result["taken_down"], false
    assert_equal result["google_play_id"], "com.mightysignal.osman"
    assert_equal result["first_scraped"], @date2.strftime("%Y-%m-%d")
    assert_equal result["name"], "Osman"
    assert_equal result["price"], 12
    assert_equal result["seller_url"], "osman-the-man.com"
    assert_equal result["description"], "my app"
    assert_equal result["in_app_purchases"], false
    assert_equal result["required_android_version"], "osman2.0"
    assert_equal result["content_rating"], "osman rated m for mature"
    assert_equal result["seller"], "osman seller of goods"
    assert_equal result["in_app_purchase_min"], 1
    assert_equal result["in_app_purchase_max"], 10
    assert_equal result["downloads_min"], 123
    assert_equal result["downloads_max"], 123123123
    assert_equal result["developer_google_play_identifier"], "osman the google play dev"
    assert_equal result["categories"], [{"id"=>@category.category_id, "name"=>"cool kids"}]
    assert_equal result["icon_url"], "osman the selfie icon"
    assert_equal result["current_version"], "osman1.0"
    assert_equal result["publisher"], {"id"=>@developer.id, "name"=>"Osman the android developer of oz", "platform"=>"android"}
    assert_includes result["headquarters"].map {|h|h["domain"]}, "osman1.com"
    assert_includes result["headquarters"].map {|h|h["domain"]}, "osman2.com"
    assert_equal result["headquarters"].length, 2
    assert_equal result["downloads_history"][0]["downloads_min"], 123
    assert_equal result["downloads_history"][0]["downloads_max"], 123123123
    assert_equal result["ratings_history"][0]["ratings_all_count"], 123
    assert_equal result["ratings_history"][0]["ratings_all_stars"], 1.23
    assert_equal result["versions_history"], [{"version"=>"osman1.0", "released"=>@date2.strftime("%Y-%m-%d")}]
  end

end
