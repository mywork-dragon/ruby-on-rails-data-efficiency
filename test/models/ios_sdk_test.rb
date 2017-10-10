require 'test_helper'
require 'mocks/elasticsearch_mock'

class IosSdkTest < ActiveSupport::TestCase

  def setup
    @model = {'my_sdk' => { 'summary' => 'hi', 'website' => 'google.com', 'classes' => ['header1']}}
  end

  test 'migrating to display sdk' do
    tags = 2.times.map do |i|
      Tag.create!(name: "#{i}_tag")
    end
    older = IosSdk.create!(name: 'older', kind: :native)
    newer = IosSdk.create!(name: 'newer', kind: :native)
    TagRelationship.create!(tag: tags.first, taggable: older)
    TagRelationship.create!(tag: tags.second, taggable: newer)
    older.migrate_to_display_sdk(newer.id)
    assert_equal(tags.map(&:id).sort, newer.tags.pluck(:id).sort)
    assert_empty(older.reload.tags)
    refute_empty(IosSdkLink.where(source_sdk: older, dest_sdk: newer))
  end

  test 'it creates an SDK manually' do
    name = 'sup'
    sdk = IosSdk.create_manual(name: name, website: 'http://google.com', kind: :native)
    assert_equal(name, sdk.name)
    assert_equal('manual', sdk.source)
  end

  test 'it upserts an SDK when creating manually' do
    name = 'sup'
    website = 'google.com'
    IosSdk.create!(name: name, kind: :native)
    sdk = IosSdk.create_manual(name: name, website: website, kind: :native)
    assert_equal(name, sdk.name)
    assert_equal(website, sdk.website)
    assert_nil(sdk.source)
  end

  test 'sync inserts new data from model into source data' do
    IosSdk.sync_manual_data(@model)
    sdk = IosSdk.find_by_name!('my_sdk')
    assert_equal('google.com', sdk.website)
    assert_equal(1, sdk.ios_sdk_source_datas.count)
  end

  test 'sync adjusts classes' do
    prev = IosSdk.create!(name: 'my_sdk', source: :manual, kind: :native)
    IosSdkSourceData.create!(name: 'previous', ios_sdk_id: prev.id)
    IosSdk.sync_manual_data(@model)
    prev.reload
    assert_equal(1, prev.ios_sdk_source_datas.count)
    assert_equal(@model['my_sdk']['classes'].first, prev.ios_sdk_source_datas.first.name)
  end

  test 'short form api_json' do
    sdk = IosSdk.create!(name: 'sup', website: 'http://hey.com', kind: :native)
    res = sdk.api_json(short_form: true)
    assert_equal sdk.id, res[:id]
    assert_equal sdk.name, res[:name]
    assert_equal 3, res.keys.count
  end

  test 'long form api_json' do
    sdk = IosSdk.create!(name: 'sup', website: 'http://hey.com', kind: :native)
    sdk.es_client = ElasticsearchMock.new
    sdk.es_client.add_response(
      { terms: { 'installed_sdks.id' => [sdk.id] } },
      [{ id: 1 }, { id: 2 }, { id: 3}]
    )
    res = sdk.api_json
    assert_equal sdk.id, res[:id]
    assert_equal sdk.name, res[:name]
    assert_equal sdk.website, res[:website]
    assert_equal :ios, res[:platform]
    assert_equal 3, res[:apps_count]
    assert_equal 6, res.keys.count
  end
end
