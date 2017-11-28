require 'test_helper'

class IosSdkWorkerTest < ActiveSupport::TestCase

  def setup
    @model = {'my_sdk' =>
              { 'name' => 'My SDK', 'uid' => 'my_sdk', 'summary' => 'hi', 'website' => 'google.com', 'classes' => ['header1'], 'frameworks' => ['my_framework']}}
  end

  test 'sync inserts new data from model into source data' do
    uid = 'my_sdk'
    IosSdkSyncWorker.new.perform(uid, @model[uid])
    sdk = IosSdk.find_by_uid!(uid)
    assert_equal('google.com', sdk.website)
    assert_equal(1, sdk.ios_sdk_source_datas.count)
    assert_equal(1, sdk.ios_classification_frameworks.count)
  end

  test 'sync adjusts classes' do
    uid = 'my_sdk'
    prev = IosSdk.create!(name: 'adsf', uid: uid, source: :manual, kind: :native)
    IosSdkSourceData.create!(name: 'previous', ios_sdk_id: prev.id)
    IosSdkSyncWorker.new.perform(uid, @model[uid])
    prev.reload
    assert_equal(1, prev.ios_sdk_source_datas.count)
    assert_equal(@model[uid]['classes'].first, prev.ios_sdk_source_datas.first.name)
  end

end
