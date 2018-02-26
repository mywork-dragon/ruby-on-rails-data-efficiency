module AppHotStoreSchema

  def app_schema
    @@APP_SCHEMA
  end

   @@VERSIONS_HISTORY_SCHEMA = {
    "version"=>String,
    "released"=>String
  }

  @@RATINGS_HISTORY_SCHEMA = {
    "start_date"=>String,
    "stop_date"=>String,
    "ratings_all_count"=>Integer,
    "ratings_all_stars"=>String
  }

  @@CATEGORIES_SCHEMA = {
    "name"=>String,
    "id"=>String
  }

  @@INSTALL_ACTIVITIES_SCHEMA = {
    "type"=>String,
    "date"=>String
  }

  @@SDK_ACTIVITY_SCHEMA = {
    "id"=>Integer,
    "name"=>String,
    "last_seen_date"=>String,
    "first_seen_date"=>String,
    "first_unseen_date"=>String,
    "activities"=>[ @@INSTALL_ACTIVITIES_SCHEMA ],
    "categories"=>[ String ],
    "installed"=>TrueClass
  }

  @@PUBLISHER_SCHEMA = {
    "name"=>String,
    "platform"=>String,
    "id"=>Integer
  }

  @@HEADQAURTER_SCHEMA = {
    "domain"=>String,
    "street_number"=>String,
    "street_name"=>String,
    "sub_premise"=>String,
    "city"=>String,
    "postal_code"=>String,
    "state"=>String,
    "state_code"=>String,
    "country"=>String,
    "country_code"=>String,
    "lat"=>String,
    "lng"=>String
  }

  @@DOWNLOADS_HISTORY_SCHEMA = {
    "start_date" => String,
    "stop_date" => String,
    "downloads_min" => Integer,
    "downloads_max" => Integer
  }

  @@APP_SCHEMA = {
    "content_rating"=>String,
    "versions_history"=>[ @@VERSIONS_HISTORY_SCHEMA ],
    "downloads_max"=>Integer,
    "seller_url"=>String,
    "google_play_id"=>String,
    "ratings_history"=>[ @@RATINGS_HISTORY_SCHEMA ],
    "name"=>String,
    "platform"=>String,
    "categories"=>[ @@CATEGORIES_SCHEMA ],
    "mobile_priority"=>String,
    "sdk_activity"=> [ @@SDK_ACTIVITY_SCHEMA ],
    "first_scanned_date"=>String,
    "all_version_rating"=>String,
    "description"=>String,
    "last_updated"=>String,
    "in_app_purchases"=>TrueClass,
    "taken_down"=>TrueClass,
    "publisher"=>@@PUBLISHER_SCHEMA,
    "seller"=>String,
    "id"=>Integer,
    "icon_url"=>String,
    "developer_google_play_identifier"=>String,
    "last_scanned_date"=>String,
    "headquarters"=>[ @@HEADQAURTER_SCHEMA ],
    "app_identifier"=>String,
    "required_android_version"=>String,
    "all_version_ratings_count"=>Integer,
    "current_version"=>String,
    "current_version_release_date"=>String,
    "downloads_history"=> [ @@DOWNLOADS_HISTORY_SCHEMA ],
    "user_base"=>String,
    "downloads_min"=>Integer,
    "in_app_purchase_max"=>Integer,
    "price"=>Integer,
    "in_app_purchase_min"=>Integer,
    "download_regions"=> [ String ],
    "has_fb_ad_spend"=>TrueClass,
    "first_scraped"=>String
  }

end