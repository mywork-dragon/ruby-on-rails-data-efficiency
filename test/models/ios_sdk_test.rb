require 'test_helper'

class IosSdkTest < ActiveSupport::TestCase

  test 'it creates an SDK manually' do
    name = 'sup'
    sdk = IosSdk.create_manual(name: name, website: 'http://google.com', kind: :native)
    assert_equal(name, sdk.name)
    assert_equal('manual', sdk.source)
  end

  test 'it upsets an SDK when creating manually' do
    name = 'sup'
    website = 'google.com'
    IosSdk.create!(name: name, kind: :native)
    sdk = IosSdk.create_manual(name: name, website: website, kind: :native)
    assert_equal(name, sdk.name)
    assert_equal(website, sdk.website)
    assert_nil(sdk.source)
  end
end
