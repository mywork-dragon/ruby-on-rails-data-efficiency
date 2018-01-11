class ApplicationHotStoreImportWorker
  include Sidekiq::Worker
  sidekiq_options queue: :hot_store_application_import, retry: 2

  def initialize
    @hot_store = AppHotStore.new
  end

  def perform(platform, application_id)
    @hot_store.write(platform, application_id)
  end

  def queue_ios_apps
    IosApp.where.not(:display_type => IosApp.display_types[:not_ios]).pluck(:id).map do |id|
      ApplicationHotStoreImportWorker.perform_async("ios", id)
    end
  end

  def queue_android_apps
    AndroidApp.pluck(:id).map do |id|
      ApplicationHotStoreImportWorker.perform_async("android", id)
    end
  end
  
  def queue_apps
    queue_ios_apps
    queue_android_apps
  end

end
