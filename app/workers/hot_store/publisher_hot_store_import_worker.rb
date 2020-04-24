class PublisherHotStoreImportWorker
  include Sidekiq::Worker
  include Utils::Workers
  sidekiq_options queue: :hot_store_application_import, retry: 2

  attr_reader :hs

  def initialize
    @hs = PublisherHotStore.new
  end

  def perform(platform, publisher_ids)
    publisher_ids.each { |publisher_id| hs.write(platform, publisher_id) }
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
        delegate_perform(self.class, IosApp::PLATFORM_NAME, group.map(&:id))
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
        delegate_perform(self.class, AndroidApp::PLATFORM_NAME, group.map(&:id))
      end
  end
end
