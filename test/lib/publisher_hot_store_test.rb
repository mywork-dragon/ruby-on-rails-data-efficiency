require 'test_helper'
require 'mocks/redis_mock'
require 'lib/hotstore/hot_store_schema_test_base'
ContactDiscoveryService.class_eval do
  def mightybit_get(path)
    {}.to_json
  end
end

class PublisherHotStoreTest < ::HotStoreSchemaTestBase

  def setup
    @redis = RedisMock.new
    @hot_store = PublisherHotStore.new(redis_store: @redis)

    @developer = AndroidDeveloper.create!(
      name: "Matt the BOBA DADDAAAAY",
      identifier: "tapioca",
    )

    @website_1 = Website.create!(
      url: "boba-daddy.com"
    )

    @domain_data_1 = DomainDatum.create!(
      name: "BOBBA DADDY THE NAME",
      legal_name: "BOBBA DADDAYYY",
      domain: "BOBBA-DADDAYYY.com",
      description: "BOBBA DADDAYYY GIVES BOBA TO ALL",
      company_type: "BOBBA DADDAYYY co",
      tags: [ "BOBBA-DADDAYYY" ],
      sector: "BOBBA DADDAYY SECTOR",
      industry_group: "BOBBA DADDAYYY inc.",
      industry: "BOBBA DADDAYYY inc...",
      sub_industry: "BOBBA DADDAYYY sub inc",
      tech_used: [ "tea", "milk" ],
      founded_year: 1925,
      time_zone: "MZ",
      utc_offset: 7,
      street_number: "123",
      street_name: "BOBBA DADDAYYY pl.",
      sub_premise: "BOBBA DADDAYYY sb",
      city: "BOBBA DADDAYYY CITY",
      postal_code: "12345",
      state: "CA",
      state_code: "CA",
      country: "USA",
      country_code: "USA",
      lat: "13.123",
      lng: "23.234",
      logo_url: "BOBBA-DADDAYYY.png",
      facebook_handle: "BOBBA DADDAYYY fb",
      linkedin_handle: "BOBBA DADDAYYY li",
      twitter_handle: "BOBBA DADDAYYY tw",
      twitter_id: "BOBBA DADDAYYY twid",
      crunchbase_handle: "BOBBA DADDAYYY cb",
      email_provider: true,
      ticker: "BBDD",
      phone: "123123123",
      alexa_us_rank: 25,
      alexa_global_rank: 26,
      google_rank: 27,
      employees: 28,
      employees_range: "123",
      market_cap: 29,
      raised: 15,
      annual_revenue: 35,
      fortune_1000_rank: 25
    )

    @website_1.update(:domain_datum => @domain_data_1)
    @developer.websites << @website_1
  end

  test 'writes publishers with correct schema and values' do
    @hot_store.write("android", @developer.id)

    stored_attributes = @hot_store.read("android", @developer.id)

    validate(publisher_schema, stored_attributes)

    assert_equal stored_attributes["name"], "Matt the BOBA DADDAAAAY"
    assert_equal stored_attributes["publisher_identifier"], "tapioca"
    assert_equal stored_attributes["id"], @developer.id
    assert_equal stored_attributes["platform"], "android"

    assert_equal @redis.sismember("publisher_keys", "publisher:android:#{@developer.id}"), "1"
  end

end
