require 'test_helper'

class IosClassificationHeaderTest < ActiveSupport::TestCase
  test 'summary method' do
    x1 = IosClassificationHeader.create!(
      name: 'x1',
      is_unique: true,
      ios_sdk_id: 1,
      collision_sdk_ids: []
    )
    x2 = IosClassificationHeader.create!(
      name: 'x2',
      is_unique: false,
      ios_sdk_id: 2,
      collision_sdk_ids: [1, 2]
    )

    res = IosClassificationHeader.new.model_summary
    assert res[x1[:name]]
    assert res[x2[:name]]
    assert_equal 2, res.keys.count

    assert_equal x1.is_unique, res[x1[:name]][:is_unique]
    assert_equal x1.ios_sdk_id, res[x1[:name]][:ios_sdk_id]
    assert_equal x1.collision_sdk_ids, res[x1[:name]][:collision_sdk_ids]
    assert_equal x2.collision_sdk_ids, res[x2[:name]][:collision_sdk_ids]
  end
end
