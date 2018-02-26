require 'test_helper'
require 'mocks/redis_mock'
require 'lib/hotstore/hot_store_schema_test_base'

class DomainDataHotStoreTest < ::HotStoreSchemaTestBase

  def setup
    @redis = RedisMock.new
    @hot_store = DomainDataHotStore.new(redis_store: @redis)

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
  end

  test 'writes domain data with correct schema' do
    @hot_store.write(@domain_data_1.as_json)

    stored_attributes = @hot_store.read(@domain_data_1.domain)

    validate(domain_data_schema, stored_attributes)

    assert_equal stored_attributes["name"], "BOBBA DADDY THE NAME"
    assert_equal stored_attributes["legal_name"], "BOBBA DADDAYYY"
    assert_equal stored_attributes["lat"], "13.123"
    assert_equal stored_attributes["crunchbase_handle"], "BOBBA DADDAYYY cb"

    assert_equal @redis.sismember("domain_data_keys", "dd:#{@domain_data_1.domain}"), "1"
  end

end
