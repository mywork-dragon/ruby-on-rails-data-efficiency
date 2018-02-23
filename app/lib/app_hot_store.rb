class AppHotStore < HotStore

  @@APP_FIELDS_TO_DELETE = {
    "ios" => [ "first_seen_ads_date", "last_seen_ads_date", "has_ad_spend" ],
    "android" => [ "first_seen_ads_date", "last_seen_ads_date" ]
  }

  def initialize()
    super

    @key_set = "app_keys"
    @compressed_fields = [ "sdk_activity", "ratings_history", "versions_history", "rankings", "description", "ad_summaries", "ratings_by_country" ]
    @required_fields = [ "app_identifier" ]

    @platform_to_class = {
      "ios" => IosApp,
      "android" => AndroidApp
    }

    @fields_to_normalize = {
      "ios" => {
        "app_store_id" => "app_identifier",
        "has_in_app_purchases" => "in_app_purchases",
        "last_updated" => "current_version_release_date"
      },
      "android" => {
        "google_play_id" => "app_identifier",
        "released" => "current_version_release_date"
      }
    }
  end

  def write(platform, app_ids, include_sdk_history: true)
    # TODO: Remove once iOS bulk export is done
    # Temporary duplicate code while Ben optimizes iOS export...
    if platform == "ios"
      
      app_ids.each do |app_id|
        default_external_json_params = {:include_sdk_history => include_sdk_history}
        extra_fields = extra_app_fields(platform)
        default_external_json_params.merge(extra_fields)

        app_object = to_class(platform).find(app_id)
        app_attributes = app_object.as_external_dump_json(default_external_json_params)

        # Merge uninstalled_sdks and installed_sdks into sdk_activity
        if include_sdk_history
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
        end

        add_ios_storefront_ratings(app_object, app_attributes) if platform == "ios"

        delete_app_fields(platform, app_attributes)

        write_entry("app", platform, app_id, app_attributes)
      end

    else

      export_options = {:include_sdk_history => include_sdk_history}
      export_results = AndroidApp.bulk_export(ids: app_ids, options: export_options)
      export_results.each do |app_id, app_attributes|
        # Merge uninstalled_sdks and installed_sdks into sdk_activity
        if include_sdk_history
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
        end
        
        # TODO: probably merge this into iOS version of bulk_export:
        # add_ios_storefront_ratings(app_object, app_attributes) if platform == "ios"
  
        delete_app_fields(platform, app_attributes)
  
        write_entry("app", platform, app_id, app_attributes)
      end

    end
  end

  def write_ad_summary(app_id, app_identifier, platform, ad_summary, async: false)
    attributes = { "ad_summaries" => ad_summary }

    # Add in required params to the app entry.
    attributes["id"] = app_id
    attributes["platform"] = platform
    attributes["app_identifier"] = app_identifier

    write_entry("app", platform, app_id, attributes, async: async)
  end

  def read(platform, app_id)
    read_entry("app", platform, app_id)
  end

  def delete(platform, app_id)
    delete_entry("app", platform, app_id)
  end

private

  def add_ios_storefront_ratings(app_object, app_attributes)
    ratings_details = app_object.ratings_info
    app_attributes["ratings_by_country"] = ratings_details

    all_ratings_count = ratings_details.map { |storefront_rating| 
      storefront_rating[:ratings_count] 
    }.compact.inject(0, &:+) # sums all the ratings_counts in list

    app_attributes["all_version_ratings_count"] = all_ratings_count

    if all_ratings_count.nil? or all_ratings_count == 0
      app_attributes["all_version_rating"] = 0
      return
    end

    storefront_ratings_average = 0
    ratings_details.each do |storefront_rating|
      ratings_count = storefront_rating[:ratings_count]
      rating_stars = storefront_rating[:rating]
      next if ratings_count.nil? or rating_stars.nil?
      
      weight = ratings_count.to_f / all_ratings_count
      storefront_ratings_average = storefront_ratings_average + ( weight * rating_stars )
    end

    app_attributes["all_version_rating"] = storefront_ratings_average
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