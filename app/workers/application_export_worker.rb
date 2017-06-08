class ApplicationExportWorker
  include Sidekiq::Worker

  sidekiq_options queue: :application_export, retry: false
  def perform(platform, application_id)
    s3_client = MightyAws::S3.new
    dumped_json = platform.to_s.classify.constantize.find(application_id).as_external_dump_json
    key = "#{dumped_json["platform"]}/#{dumped_json["platform"]}-#{dumped_json["id"]}.json.gz"
    puts "storing #{key}"
    s3_client.store(
      bucket: Rails.application.config.application_export_bucket,
      key_path: key,
      data_str: dumped_json.to_json
    )
  end

  def queue_ios_apps
    IosApp.pluck(:id).map do |id|
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
