require 'test_helper'
require 'mocks/redis_mock'
require 'lib/hotstore/hot_store_schema_test_base'

class SdkHotStoreTest < ::HotStoreSchemaTestBase

  def setup
    @redis = RedisMock.new
    @hot_store = SdkHotStore.new(redis_store: @redis)

    @sdk_1 = IosSdk.create!(
      name: 'Leanplum-iOS-Location',
      website: 'https://www.leanplum.com',
      open_source: true,
      kind: 1,
      summary: "smmaryyaydfasdf",
      favicon: "https://www.google.com/s2/favicons?domain=leanplum.com"
    )

    tag = Tag.create!(name: "copper is bad")

    @sdk_1.tags << tag
  end

  test 'writes sdks with correct schema and values' do
    @hot_store.write("ios", @sdk_1.id)
    stored_attributes = @hot_store.read("ios", @sdk_1.id)
    ap stored_attributes
    validate(sdk_schema, stored_attributes)

    assert_equal @redis.sismember("sdk_keys", "sdk:ios:#{@sdk_1.id}"), "1"
  end

end
