require 'test_helper'

class GooglePlayServiceTest < ActiveSupport::TestCase


  def basic_presence_check(res, ignored: [])
    attrs = %i(
      name
      description
      price
      seller
      seller_url
      seller_email
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

  end

end
