class ApplicationPublisherExportWorker < ExportWorker

  def perform(platform, publisher_id)
    dumped_json = platform.to_s.classify.constantize.find(publisher_id).api_json.as_json
    key = "#{platform}s:#{dumped_json["id"]}"
    export_store.set(key, ActiveSupport::Gzip.compress(dumped_json.to_json))
    export_store.sadd("#{platform}s:set", key)
  end

  def queue_ios
    IosDeveloper.pluck(:id).map do |id|
      ApplicationPublisherExportWorker.perform_async(:ios_developer, id)
    end
  end
  
  def queue_android
    AndroidDeveloper.pluck(:id).map do |id|
      ApplicationPublisherExportWorker.perform_async(:android_developer, id)
    end
  end
  
  def queue_jobs
    queue_ios
    queue_android
  end


end
