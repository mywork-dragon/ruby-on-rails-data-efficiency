require 'test_helper'

class RankingsAccessorTest < ActiveSupport::TestCase
  test 'delegate has same methods as accessor' do
    x = RankingsAccessor.new
    assert_equal [:delegate], (x.public_methods(false) -  x.delegate.public_methods(false))
    assert_equal [], (x.delegate.public_methods(false) -  x.public_methods(false))
  end
end
