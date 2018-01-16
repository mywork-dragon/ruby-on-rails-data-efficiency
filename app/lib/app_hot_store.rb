class AppHotStore < HotStore

  @@APP_FIELDS_TO_NORMALIZE = {
    "ios" => {
      "app_store_id" => "app_identifier",
      "has_in_app_purchases" => "in_app_purchases"
    },
    "android" => {
      "google_play_id" => "app_identifier",
      "released" => "current_version_release_date"
    }
  }

  @@APP_FIELDS_TO_DELETE = {
    "ios" => [ "first_seen_ads_date", "last_seen_ads_date", "has_ad_spend" ],
    "android" => [ "first_seen_ads_date", "last_seen_ads_date" ]
  }

  @@REQUIRED_FIELDS = [ "app_identifier" ]

  def initialize()
    super

    @key_set = "app_keys"
    @compressed_fields = [ "sdk_activity", "ratings_history", "versions_history", "rankings", "description", "ad_summaries" ]
    @platform_to_class = {
      "ios" => IosApp,
      "android" => AndroidApp
    }
  end

  def write(platform, app_id)
    app_key = key("app", platform, app_id)
    extra_fields = extra_app_fields(platform)

    app_attributes = to_class(platform).find(app_id).as_external_dump_json(extra_fields)

    # Merge uninstalled_sdks and installed_sdks into sdk_activity
    sdk_activity = []
    app_attributes["installed_sdks"].each do |install_info|
      install_info["installed"] = true
      sdk_activity << install_info
    end
    app_attributes["uninstalled_sdks"].each do |install_info|
      install_info["installed"] = false
      sdk_activity << install_info
    end
    app_attributes["sdk_activity"] = sdk_activity
    app_attributes.delete("installed_sdks")
    app_attributes.delete("uninstalled_sdks")

    normalize_app_fields(platform, app_attributes)
    delete_app_fields(platform, app_attributes)

    write_entry("app", platform, app_id, app_attributes) if all_required_fields_exist?(app_attributes)
  end

  def write_ad_summary(app_id, app_identifier, platform, ad_summary)
    existing_entry = read(platform, app_id)

    attributes = { "ad_summaries" => ad_summary }

    # Add in required params if the app entry has not yet been
    # imported into the hotstore.
    attributes["id"] = app_id if existing_entry["id"].nil?
    attributes["platform"] = platform if existing_entry["platform"].nil?
    attributes["app_identifier"] = app_identifier if existing_entry["app_identifier"].nil?

    write_entry("app", platform, app_id, attributes)
  end

  def read(platform, app_id)
    read_entry("app", platform, app_id)
  end

  def delete(platform, app_id)
    delete_entry("app", platform, app_id)
  end

private
  
  def all_required_fields_exist?(app_attributes)
    @@REQUIRED_FIELDS.each do |field|
      return false if app_attributes[field].nil?
    end
    true
  end

  def all_required_fields_exist?(app_attributes)
    @@REQUIRED_FIELDS.each do |field|
      return false if app_attributes[field].nil?
    end
    true
  end

  def normalize_app_fields(platform, app_attributes)
    normalized_fields = @@APP_FIELDS_TO_NORMALIZE[platform]

    normalized_fields.each do |from, to|
      if not app_attributes.key?(to)
        app_attributes[to] = app_attributes[from]
        app_attributes.delete(from)
      end
    end
  end

  def delete_app_fields(platform, app_attributes)
    @@APP_FIELDS_TO_DELETE[platform].each do |field|
      app_attributes.delete(field)
    end
  end

  def extra_app_fields(platform)
    if platform == "ios"
      return {
        :extra_from_app => [ "headquarters" ],
        :extra_sdk_fields => [ "activities" ]
      }
    else
      return {
        :extra_from_app => [ "headquarters" ],
        :extra_sdk_fields => [ "activities" ]
      }
    end
  end

end