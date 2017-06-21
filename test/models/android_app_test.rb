require 'test_helper'
require 'mocks/elasticsearch_mock'

class AndroidAppTest < ActiveSupport::TestCase

  def setup
    @app = AndroidApp.create!(
      app_identifier: 'com.mightysignal.osman',
      user_base: :elite
    )
    @snapshot = AndroidAppSnapshot.create!(
      name: 'Osman',
      description: 'my app',
      price: 0
    )
    @sdk = AndroidSdk.create!(name: 'sup', website: 'hello.com', kind: :native)
    @app.update!(newest_android_app_snapshot: @snapshot)
    @app.es_client = ElasticsearchMock.new
    @app.es_client.add_response(
      { term: { 'id' => @app.id } },
      [{
        'id' => @app.id,
        'first_scanned' => 'some_value',
        'last_scanned' => 'some_value',
        'installed_sdks' => [ {'id' => @sdk.id, 'first_seen_date' => 'some_value'}],
        'uninstalled_sdks' => [ {'id' => @sdk.id, 'first_seen_date' => 'some_value', 'last_seen_date' => 'another_value'}]
      }]
    )
  end

  def assert_base_attributes(res)
    assert_instance_of Integer, res[:id]
    assert_equal :android, res[:platform]
    assert_instance_of String, res[:google_play_id]
    assert res.key?(:publisher)
    assert_instance_of String, res[:mobile_priority]
    assert_instance_of String, res[:user_base]
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

  test 'short format' do
    res = @app.api_json(short_form: true)
    assert_base_attributes(res)
    assert_nil res[:installed_sdks]
    assert_nil res[:uninstalled_sdks]
  end

  test 'long format' do
    res = @app.api_json
    assert_base_attributes(res)
    assert_extended_attributes(res)
  end
end
