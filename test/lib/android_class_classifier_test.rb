require 'test_helper'

class AndroidClassClassifierTest < ActiveSupport::TestCase
  test "load model works" do
    apc = AndroidClassClassifier.new()

    sdks, paths = apc.classify(['butterknife.internal.ImmutableList'])
    assert_equal 'butterknife', sdks.to_a[0][0]
    sdks, paths = apc.classify(['com.braintreepayments.api.BraintreeBrowserSwitchActivity'])
    assert_equal 'braintree', sdks.to_a[0][0]

  end
end
