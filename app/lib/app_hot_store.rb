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

  def initialize()
    super

    @key_set = "app_keys"
    @compressed_fields = [ "sdk_activity", "ratings_history", "versions_history", "rankings", "description" ]
    @platform_to_class = {
      "ios" => IosApp,
      "android" => AndroidApp
    }
  end

  def write(platform, app_id)
    app_key = key("app", platform, app_id)
    extra_fields = extra_app_fields(platform)

    # TODO: Change to use to_class helper once platform is changed to "ios" and "android"
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

    write_entry("app", platform, app_id, app_attributes)
  end

  def read(platform, app_id)
    read_entry("app", platform, app_id)
  end

  def delete(platform, app_id)
    delete_entry("app", platform, app_id)
  end

private

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