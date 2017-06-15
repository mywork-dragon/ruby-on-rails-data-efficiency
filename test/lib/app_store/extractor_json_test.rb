require 'test_helper'

class ExtractorJsonTest < ActiveSupport::TestCase

  def setup
    @test_app_json = JSON.parse(File.open(File.join(Rails.root, 'test', 'data', 'test_app.json')).read)
    @extractor = AppStoreHelper::ExtractorJson.new(@test_app_json)
  end

  test 'it correctly calculates etag' do
    assert_equal '549eafd5b785c539f548fd68e531324a', @extractor.etag
  end

  test 'it correctly extracts category_ids' do
    expected = {:primary=>6004, :secondary=>[6009]}
    assert_equal expected, @extractor.category_ids
  end

  test 'it correctly extracts seller_name' do
    assert_equal 'Bleacher Report', @extractor.seller_name
  end

  test 'it correctly extracts currency' do
    assert_equal 'USD', @extractor.currency
  end

  test 'it correctly extracts bundle_identifier' do
    assert_equal 'com.bleacherreport.TeamStream', @extractor.bundle_identifier
  end

  test 'it correctly extracts game_center_enabled' do
    assert_not @extractor.game_center_enabled
  end

  test 'it correctly extracts icon_url_100x100' do
    assert_equal 'http://is5.mzstatic.com/image/thumb/Purple127/v4/e0/77/c3/e077c3b9-e7d5-0fa8-a4d6-fa0ff5ebc57c/source/100x100bb.jpg', @extractor.icon_url_100x100
  end

  test 'it correctly extracts icon_url_512x512' do
    assert_equal 'http://is5.mzstatic.com/image/thumb/Purple127/v4/e0/77/c3/e077c3b9-e7d5-0fa8-a4d6-fa0ff5ebc57c/source/512x512bb.jpg', @extractor.icon_url_512x512
  end

  test 'it correctly extracts icon_url_60x60' do
    assert_equal 'http://is5.mzstatic.com/image/thumb/Purple127/v4/e0/77/c3/e077c3b9-e7d5-0fa8-a4d6-fa0ff5ebc57c/source/60x60bb.jpg', @extractor.icon_url_60x60
  end

  test 'it correctly extracts ratings_all_count' do
    assert_equal 17044, @extractor.ratings_all_count
  end

  test 'it correctly extracts ratings_all_stars' do
    assert_equal 4.5, @extractor.ratings_all_stars
  end

  test 'it correctly extracts ratings_current_count' do
    assert_equal 53, @extractor.ratings_current_count
  end

  test 'it correctly extracts ratings_current_stars' do
    assert_equal 4.5, @extractor.ratings_current_stars
  end

  test 'it correctly extracts released' do
    assert_equal '2017-06-05', @extractor.released.to_s
  end

  test 'it correctly extracts screenshot_urls' do
    assert_equal ["http://a1.mzstatic.com/us/r30/Purple122/v4/db/f3/b3/dbf3b307-97bb-d217-07e7-d21e07e1ad2b/screen696x696.jpeg", "http://a1.mzstatic.com/us/r30/Purple122/v4/c5/30/93/c530936f-7132-d3ce-6b79-fe7072a4805e/screen696x696.jpeg", "http://a3.mzstatic.com/us/r30/Purple111/v4/87/78/36/87783692-dc93-c9c8-4ea0-1d6bedd6bfb3/screen696x696.jpeg", "http://a1.mzstatic.com/us/r30/Purple122/v4/1b/a6/8b/1ba68b65-5f09-a36c-4868-964d79afe532/screen696x696.jpeg", "http://a2.mzstatic.com/us/r30/Purple122/v4/e1/83/6e/e1836ee7-fe42-e0d8-962d-a469415e3f02/screen696x696.jpeg"], @extractor.screenshot_urls
  end

  test 'it correctly extracts first_released' do
    assert_equal '2011-03-08', @extractor.first_released.to_s
  end

  test 'it correctly extracts required_ios_version' do
    assert_equal '9.0', @extractor.required_ios_version
  end

  test 'it correctly extracts recommended_age' do
    assert_equal '12+', @extractor.recommended_age
  end

  test 'it correctly extracts developer_app_store_identifier' do
    assert_equal 418075938, @extractor.developer_app_store_identifier
  end

  test 'it correctly extracts size' do
    assert_equal '85652480', @extractor.size
  end

  test 'it correctly extracts category_names' do
    expected = {:primary=>"Sports", :secondary=>["News"]}
    assert_equal expected, @extractor.category_names
  end

  test 'it correctly extracts seller_url' do
    assert_equal 'http://bleacherreport.com/mobile', @extractor.seller_url
  end

  test 'it correctly extracts price' do
    assert_equal 0, @extractor.price
  end

  test 'it correctly extracts version' do
    assert_equal '5.2', @extractor.version
  end

  test 'it correctly extracts name' do
    assert_equal 'Bleacher Report: Sports news, scores, & highlights', @extractor.name
  end

  test 'it correctly extracts app_identifier' do
    assert_equal 418075935, @extractor.app_identifier
  end

  test 'it correctly extracts collection_identifier' do
    assert_nil @extractor.collection_identifier
  end

  test 'it correctly extracts artist_identifier' do
    assert_equal 418075938, @extractor.artist_identifier
  end

  test 'it correctly extracts alternate_identifier' do
    assert_equal 418075938, @extractor.alternate_identifier
  end

  test 'it correctly verify_ios!' do
    assert_nil @extractor.verify_ios!
  end

  test 'it correctly extracts description' do
    assert_equal "Your Team's News First!", @extractor.description
  end

  test 'it correctly extracts release_notes' do
    assert_equal "What's New in 5.2?", @extractor.release_notes
  end

end