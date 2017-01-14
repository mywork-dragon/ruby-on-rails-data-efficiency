require 'test_helper'

class FbMauWorkerTest < ActiveSupport::TestCase

  def setup
    @worker = FbMauWorker.new
  end

  test 'parses out the CSV contents into a map' do
    csv_contents = "
    classdump_id, facebook_app_id
    1,1
    2,I did not read instructions 123123
    3,fb3
    "
    @worker.stub :latest_csv_contents, csv_contents do
      map = @worker.classdump_map
      assert_equal '1', '1'
      assert_equal '3', '3'
      assert 2, map.keys.count
    end
  end

  test 'converts classdump-to-fb-app map to ios-app-to-fb-app' do
    classdump_map = {1 => '2', 3 => '6', 4 => '7'}
    @worker.stub :fetch_apps, [[1, 1], [3, 3], [1, 4]] do
      ios_app_map = @worker.convert_cd_to_ios_app_map(classdump_map)
      assert_equal ['2', '7'], ios_app_map[1]
      assert_equal ['6'], ios_app_map[3]
    end
  end

  test 'properly merges known associations with computed ones' do
    ios_to_fb_apps = {1 => [1], 2 => [2], 3 => [3]}
    known = {"1" => 5, "2" => nil}
    @worker.stub :retrieve_known_associations, known do
      @worker.merge_known!(ios_to_fb_apps)
      assert_equal [3], ios_to_fb_apps[3]
      assert_equal [5], ios_to_fb_apps[1]
      assert ios_to_fb_apps[2].nil?
    end
  end

  test 'ensures each app only maps to one FB app id' do
    ios_to_fb_apps = {1 => [1], 2 => [2, 10], 3 => [3]}
    @worker.ensure_single_pair!(ios_to_fb_apps)
    assert_equal 1, ios_to_fb_apps[1]
    assert_equal 3, ios_to_fb_apps[3]
    assert ios_to_fb_apps[2].nil?
  end

  test 'updates ios apps that are incorrectly labeled' do
    first = IosApp.create!(id: 123, app_identifier: 123, fb_app_id: 123)
    second = IosApp.create!(id: 456, app_identifier: 456, fb_app_id: nil)
    third = IosApp.create!(id: 789, app_identifier: 789, fb_app_id: 789)

    FbMauWorker.new.update_ios_apps!(
      "123" => 123,
      "456" => 456,
      "789" => nil
    )

    assert_equal 123, first.reload.fb_app_id
    assert_equal 456, second.reload.fb_app_id
    assert_equal nil, third.reload.fb_app_id
  end
end
