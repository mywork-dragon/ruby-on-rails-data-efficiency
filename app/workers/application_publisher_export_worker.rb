class ApplicationPublisherExportWorker
  include Sidekiq::Worker

  sidekiq_options queue: :application_export, retry: false
  def perform(platform, publisher_id)
    s3_client = MightyAws::S3.new
    dumped_json = platform.to_s.classify.constantize.find(publisher_id).api_json.as_json
    key = "#{dumped_json["platform"]}/#{dumped_json["platform"]}-#{dumped_json["id"]}.json.gz"
    s3_client.store(
      bucket: Rails.application.config.application_publisher_export_bucket,
      key_path: key,
      data_str: dumped_json.to_json
    )
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
