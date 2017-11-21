require 'test_helper'

class RankingsAccessorTest < ActiveSupport::TestCase
  test 'delegate has same methods as accessor' do
    x = RankingsAccessor.new

    # Using RankingsAccessor.any_instance.stub method in tests monkey patches 
    # __android_categories_without_any_instance__ method.
    assert_equal [], (x.public_methods(false) - x.delegate.public_methods(false)) - [:delegate, :__android_categories_without_any_instance__]
    assert_equal [], (x.delegate.public_methods(false) -  x.public_methods(false))
  end
end
