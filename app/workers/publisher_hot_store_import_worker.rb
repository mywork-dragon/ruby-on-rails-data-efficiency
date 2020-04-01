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
    IosDeveloper.find_in_batches(start:1, batch_size: 1000) do |group|
      group.each { |iosd| PublisherHotStoreImportWorker.perform_async('ios', iosd.id) }
    end
  end

  def queue_android_publishers
    AndroidDeveloper.find_in_batches(start:1, batch_size: 1000) do |group|
      group.each { |andrd| PublisherHotStoreImportWorker.perform_async('android', andrd.id) }
    end
  end

  def queue_publishers
    queue_ios_publishers
    queue_android_publishers
  end

end
