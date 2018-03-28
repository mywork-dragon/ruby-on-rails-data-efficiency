require 'test_helper'

class GooglePlayServiceTest < ActiveSupport::TestCase

  test 'uber attributes (non-compressed) are all correctly parsed' do
    page = open('test/data/google_play_uber.html').read()
    res = GooglePlayService.new(page).attributes('com.ubercab')
    basic_presence_check(res, ignored: [
      :size, :in_app_purchases_range
    ])
    assert res[:similar_apps].count > 0
    assert_equal 100_000_000..500_000_000, res[:downloads]
  end

  test 'uber attributes (compressed) are correctly parsed' do
    page = open('test/data/google_play_uber_compressed.html').read()
    res = GooglePlayService.new(page).attributes('com.ubercab')
    basic_presence_check(res, ignored: [
      :size, :in_app_purchases_range
    ])
    assert res[:similar_apps].count > 0
    assert_equal 100_000_000..500_000_000, res[:downloads]
  end

  test 'volleyball attributes (compressed) are correctly parsed' do
    page = open('test/data/google_play_volleyball.html').read()
    res = GooglePlayService.new(page).attributes('com.mwolpert.SGWabuVolleyball')
    basic_presence_check(res, ignored: [
      :in_app_purchases_range, :seller_url
    ])
    assert_equal(100..500, res[:downloads])
  end

  test 'snapchat attributes (compressed) are correctly parsed' do
    page = open('test/data/google_play_snapchat_compressed.html').read()
    res = GooglePlayService.new(page).attributes('com.snapchat.android')
    basic_presence_check(res, ignored: [
      :size
    ])
    assert_equal true, res[:in_app_purchases]
    assert res[:in_app_purchases_range]
    assert res[:similar_apps].count > 0
    assert res[:downloads].present?
    assert_equal 500_000_000..1_000_000_000, res[:downloads]
  end

  test 'web radio attributes (uncompressed) are correctly parsed' do
    page = open('test/data/google_play_web_radio.html').read()
    res = GooglePlayService.new(page).attributes('radio.rama.web')
    basic_presence_check(res, ignored: [:size, :in_app_purchases_range])
  end

  test 'tricky developer name with slash is parsed' do
    page = open('test/data/google_play_newsradio.html').read()
    res = GooglePlayService.new(page).attributes('radio.rama.web')
    basic_presence_check(res, ignored: [:size, :in_app_purchases_range, :in_app_purchases])
  end

  def basic_presence_check(res, ignored: [])
    attrs = %i(
      name
      description
      price
      seller
      seller_url
      category_name
      category_id
      released
      size
      top_dev
      in_app_purchases
      in_app_purchases_range
      required_android_version
      version
      downloads
      content_rating
      ratings_all_stars
      ratings_all_count
      similar_apps
      screenshot_urls
      icon_url_300x300
      developer_google_play_identifier
    ) - ignored
    attrs.each do |a|
      assert(!res[a].nil?, "Missing field #{a}")
    end
    # ensure valid app identifiers
    assert_equal([], res[:similar_apps].select { |x| /[^\w.]/.match(x) })
  end
end
