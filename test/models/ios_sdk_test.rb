require 'test_helper'

class IosSdkTest < ActiveSupport::TestCase

  def setup
    @model = {'my_sdk' => { 'summary' => 'hi', 'website' => 'google.com', 'classes' => ['header1']}}
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
end
