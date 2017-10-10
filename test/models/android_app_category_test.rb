require 'test_helper'

class AndroidAppCategoryTest < ActiveSupport::TestCase
  test 'display name is calculated correctly' do
    assert_equal 'Sports (Games)', AndroidAppCategory.find_by_category_id('GAME_SPORTS').display_name
    assert_equal 'Education', AndroidAppCategory.find_by_category_id('EDUCATION').display_name
  end
end
