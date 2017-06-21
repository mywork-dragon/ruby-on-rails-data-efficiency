require 'test_helper'
require 'mocks/elasticsearch_mock'

class IosAppTest < ActiveSupport::TestCase

  def setup
    @app = IosApp.create!(
      app_identifier: 123123123,
      user_base: :elite,
      released: 2.days.ago
    )
    @snapshot = IosAppSnapshot.create!(
      name: 'Osman',
      description: 'my app',
      price: 0
    )
    @sdk = IosSdk.create!(name: 'sup', website: 'hello.com', kind: :native)
    @app.update!(newest_ios_app_snapshot: @snapshot)
    @store = AppStore.create!(name: 'United States', country_code: 'US', display_priority: 1, enabled: true)
    @int_snapshot = IosAppCurrentSnapshot.create!(
      name: 'different_name',
      ios_app_id: @app.id,
      price: 10,
      mobile_priority: :high,
      user_base: :elite,
      app_store_id: @store.id,
      released: 10.days.ago
    )
    @category = IosAppCategory.create!(name: 'Travel')
    IosAppCategoriesCurrentSnapshot.create!(
      ios_app_current_snapshot_id: @int_snapshot.id,
      ios_app_category_id: @category.id,
      kind: :primary
    )
    @app.es_client = ElasticsearchMock.new
    @app.es_client.add_response(
      { term: { 'id' => @app.id } },
      [{
        'id' => @app.id,
        'first_scanned' => 'some_value',
        'last_scanned' => 'some_value',
        'first_seen_ads' => 1.week.ago.to_s,
        'last_seen_ads' => 1.week.ago.to_s,
        'installed_sdks' => [ {'id' => @sdk.id, 'first_seen_date' => 'some_value'}],
        'uninstalled_sdks' => [ {'id' => @sdk.id, 'first_seen_date' => 'some_value', 'last_seen_date' => 'another_value'}]
      }]
    )
  end

  def assert_base_attributes(res)
    assert_instance_of Integer, res[:id]
    assert_equal :ios, res[:platform]
    assert_instance_of Integer, res[:app_store_id]
    assert_instance_of Date, res[:original_release_date]
    assert res.key?(:publisher)
    assert_instance_of String, res[:mobile_priority]
    assert_instance_of String, res[:user_base]
    assert_instance_of String, res[:first_seen_ads_date]
    assert_instance_of String, res[:last_seen_ads_date]
    assert_instance_of String, res[:last_updated]
    assert [FalseClass, TrueClass].include?(res[:has_ad_spend].class)
    assert_equal 1, res[:categories].count
    assert_equal 'primary', res[:categories].first[:type]
  end

  def assert_extended_attributes(res)
    assert_instance_of Array, res[:installed_sdks]
    assert_instance_of Array, res[:uninstalled_sdks]
    assert_sdk_dates(res[:installed_sdks], res[:uninstalled_sdks])
  end

  def assert_sdk_dates(installed, uninstalled)
    installed.each do |sdk|
      refute_nil sdk[:first_seen_date]
      assert_nil sdk[:last_seen_date]
    end

    uninstalled.each do |sdk|
      refute_nil sdk[:first_seen_date]
      refute_nil sdk[:last_seen_date]
    end
  end

  test 'short form json' do
    res = @app.api_json(short_form: true)
    assert_base_attributes(res)
  end

  test 'long form json' do
    res = @app.api_json
    assert_base_attributes(res)
    assert_extended_attributes(res)
  end
end
