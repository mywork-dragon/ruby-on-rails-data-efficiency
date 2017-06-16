require 'test_helper'
require 'mocks/elasticsearch_mock'
require 'byebug'

class AndroidSdkTest < ActiveSupport::TestCase

  test 'short form api_json' do
    sdk = AndroidSdk.create!(name: 'sup', website: 'http://hey.com', kind: :native)
    res = sdk.api_json(short_form: true)
    assert_equal sdk.id, res[:id]
    assert_equal sdk.name, res[:name]
    assert_equal 2, res.keys.count
  end

  test 'long form api_json' do
    sdk = AndroidSdk.create!(name: 'sup', website: 'http://hey.com', kind: :native)
    sdk.es_client = ElasticsearchMock.new
    sdk.es_client.add_response(
      { terms: { 'installed_sdks.id' => [sdk.id] } },
      [{ id: 1 }, { id: 2 }, { id: 3}]
    )
    res = sdk.api_json
    assert_equal sdk.id, res[:id]
    assert_equal sdk.name, res[:name]
    assert_equal sdk.website, res[:website]
    assert_equal :android, res[:platform]
    assert_equal 3, res[:apps_count]
    assert_equal 5, res.keys.count
  end
end
