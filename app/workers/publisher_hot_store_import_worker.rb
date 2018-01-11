class PublisherHotStoreImportWorker
  include Sidekiq::Worker
  sidekiq_options queue: :hot_store_application_import, retry: 2

  def initialize
    @hot_store = PublisherHotStore.new
  end

  def perform(platform, publisher_id)
    @hot_store.write(platform, publisher_id)
  end

  def queue_ios_publishers
    IosDeveloper.pluck(:id).map do |id|
      PublisherHotStoreImportWorker.perform_async("ios", id)
    end
  end

  def queue_android_publishers
    AndroidDeveloper.pluck(:id).map do |id|
      PublisherHotStoreImportWorker.perform_async("android", id)
    end
  end
  
  def queue_publishers
    queue_ios_publishers
    queue_android_publishers
  end

end
