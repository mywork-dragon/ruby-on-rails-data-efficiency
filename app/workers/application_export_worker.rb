class ApplicationExportWorker < ExportWorker

  def initialize
    @ad_attribution_sdks = nil
  end

  def feed_key(platform, application_id)
    "#{platform}s:#{application_id}"
  end

  def fetch_app_record(platform, application_id)
    key = feed_key(platform, application_id)
    data =  ActiveSupport::Gzip.decompress(ExportWorker.new.export_store.get(key))
    feed_data = JSON.parse(data)
  end

  def set_attribution_sdks
    @ad_attribution_sdks ||= {'ios_app' => Tag.find(24).ios_sdks.pluck(:id), 'android_app' => Tag.find(24).android_sdks.pluck(:id)}
  end

  def get_ad_attribution_sdks(platform, application_id)
    feed_data = fetch_app_record(platform, application_id)
    set_attribution_sdks
    attribution_sdk_ids = @ad_attribution_sdks[platform]
    feed_data['installed_sdks'].select {|sdk| attribution_sdk_ids.include?(sdk["id"])}
  end

  def perform(platform, application_id)
    dumped_json = platform.to_s.classify.constantize.find(application_id).as_external_dump_json
    key = feed_key(platform, application_id)
    export_store.set(key, ActiveSupport::Gzip.compress(dumped_json.to_json))
    export_store.sadd("#{platform}s:set", key)
  end

  def queue_ios_apps
    # Export all apps which are iOS apps.
    IosApp.where.not(:display_type => IosApp.display_types[:not_ios]).pluck(:id).map do |id|
      ApplicationExportWorker.perform_async(:ios_app, id)
    end
  end
  
  def queue_android_apps
    AndroidApp.pluck(:id).map do |id|
      ApplicationExportWorker.perform_async(:android_app, id)
    end
  end
  
  def queue_apps
    queue_ios_apps
    queue_android_apps
  end


end
