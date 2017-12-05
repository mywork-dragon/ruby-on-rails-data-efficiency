class ApplicationExportWorker < ExportWorker

  def perform(platform, application_id)
    dumped_json = platform.to_s.classify.constantize.find(application_id).as_external_dump_json
    key = "#{platform}s:#{dumped_json["id"]}"
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
