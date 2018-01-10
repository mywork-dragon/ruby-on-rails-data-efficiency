class HotStore

  @@STARTUP_NODES = [
    {:host => ENV['HOT_STORE_REDIS_URL'], :port => ENV['HOT_STORE_REDIS_PORT'] }
  ]

  @@MAX_CONNECTIONS = (ENV['HOT_STORE_REDIS_MAX_CONNECTIONS'] || 1).to_i

  @@APP_KEY_SET = "app_keys"

  @@FIELDS_TO_COMPRESS = {
    "app" => [ "sdk_activity", "ratings_history", "versions_history", "rankings", "description" ]
  }

  @@APP_FIELDS_TO_NORMALIZE = {
    "ios_app" => {
      "app_store_id" => "app_identifier",
      "has_in_app_purchases" => "in_app_purchases"
    },
    "android_app" => {
      "google_play_id" => "app_identifier",
      "released" => "current_version_release_date"
    }
  }

  @@APP_FIELDS_TO_DELETE = {
    "ios_app" => [ "platform", "first_seen_ads_date", "last_seen_ads_date", "has_ad_spend" ],
    "android_app" => [ "platform", "first_seen_ads_date", "last_seen_ads_date" ]
  }

  def initialize()
    @redis_store = RedisCluster.new(@@STARTUP_NODES, @@MAX_CONNECTIONS)
  end

  def write_app(platform, app_id)
    app_key = key("app", platform, app_id)
    extra_fields = extra_app_fields(platform)
    app_attributes = platform.to_s.classify.constantize.find(app_id).as_external_dump_json(extra_fields)

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

    attributes_array = []
    compressed_attributes = {} # Save the compressed attributes seperately since hmset doesn't handle compressed encodings.

    app_attributes.each do |key, value|
      if @@FIELDS_TO_COMPRESS["app"].include? key
        compressed_attributes[key] = ActiveSupport::Gzip.compress(value.to_json)
      else
        attributes_array << key.to_s
        attributes_array << value.to_json
      end
    end
    
    @redis_store.hmset(app_key, attributes_array)

    compressed_attributes.each do |key, value|
      @redis_store.hset(app_key, key, value)
    end

    @redis_store.sadd(@@APP_KEY_SET, app_key)
  end

  def read_app(platform, app_id)
    app_key = key("app", platform, app_id)

    app_attributes = {}
    
    cursor = read_scanned_attributes(app_key, "0", app_attributes)
    while cursor != "0"
      cursor = read_scanned_attributes(app_key, cursor, app_attributes)
    end

    app_attributes
  end

  def delete_app(platform, app_id)
    app_key = key("app", platform, app_id)
    @redis_store.srem(@@APP_KEY_SET, app_key)
    @redis_store.del(app_key)
  end

private

  def key(type, platform, application_id)
    "#{type}:#{platform}s:#{application_id}"
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
    if platform == "ios_app"
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

  def read_scanned_attributes(app_key, app_cursor, app_attributes)
    cursor, attributes = @redis_store.hscan(app_key, app_cursor)
    attributes.each do |attribute_tuple|
      if @@FIELDS_TO_COMPRESS["app"].include? attribute_tuple[0]
        app_attributes[attribute_tuple[0]] = ActiveSupport::Gzip.decompress(attribute_tuple[1])
      else
        app_attributes[attribute_tuple[0]] = attribute_tuple[1]
      end
    end
    cursor
  end

end