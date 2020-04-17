class PublisherHotStoreImportWorker
  include Sidekiq::Worker
  sidekiq_options queue: :hot_store_application_import, retry: 2

  def perform(platform, publisher_id)
    @hs ||= PublisherHotStore.new
    @hs.write(platform, publisher_id)
  end

  def queue_publishers
    queue_ios_publishers
    queue_android_publishers
  end

  def queue_ios_publishers
    IosApp.relevant_since(HotStore::TIME_OF_RELEVANCE)
      .joins(:ios_developer)
      .select('DISTINCT ios_developer_id as id')
      .find_in_batches(start:1, batch_size: 1000) do |group|
        # Returns [#<IosApp id: 1>, ...] but that's the developer id, not the app id. Hack to avoid:
        # RuntimeError Exception: Primary key not included in the custom select clause
        # Trown by find_in_batches since we're only selecting the developer id
        group.each { |iosd| self.class.perform_async('ios', iosd.id) }
      end
  end

  def queue_android_publishers
    AndroidApp.relevant_since(HotStore::TIME_OF_RELEVANCE)
      .joins(:android_developer)
      .select('DISTINCT android_developer_id as id')
      .find_in_batches(start:1, batch_size: 1000) do |group|
        # Returns [#<AndroidApp id: 1>, ...] but that's the developer id, not the app id. Hack to avoid:
        # RuntimeError Exeption: Primary key not included in the custom select clause
        # Trown by find_in_batches since we're only selecting the developer id
        group.each { |andrd| self.class.perform_async('android', andrd.id) }
      end
  end
end
