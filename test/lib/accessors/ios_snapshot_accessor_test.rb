require 'test_helper'

class IosSnapshotAccessorTest < ActiveSupport::TestCase
  test 'delegate has same methods as accessor' do
    x = IosSnapshotAccessor.new
    assert_equal [:delegate], (x.public_methods(false) -  x.delegate.public_methods(false))
    assert_equal [], (x.delegate.public_methods(false) -  x.public_methods(false))
  end
end
