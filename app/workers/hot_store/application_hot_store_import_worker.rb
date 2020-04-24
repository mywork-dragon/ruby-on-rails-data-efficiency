class ApplicationHotStoreImportWorker
  include Sidekiq::Worker
  include Utils::Workers

  sidekiq_options queue: :hot_store_application_import, retry: 2

  attr_reader :hot_store

  BATCH_SIZE = 1000

  def initialize
    @hot_store = AppHotStore.new
  end

  def perform(platform, application_ids)
    hot_store.write(platform, application_ids)
  end

  def queue_apps
    queue_ios_apps
    queue_android_apps
  end

  def queue_ios_apps
    IosApp
      .relevant_since(HotStore::TIME_OF_RELEVANCE)
      .select("#{IosApp.table_name}.id")
      .find_in_batches(batch_size: BATCH_SIZE) do |group|
        delegate_perform(self.class, IosApp::PLATFORM_NAME, group.map(&:id))
      end
  end

  def queue_android_apps
    AndroidApp
      .relevant_since(HotStore::TIME_OF_RELEVANCE)
      .select("#{AndroidApp.table_name}.id")
      .find_in_batches(batch_size: BATCH_SIZE) do |group|
        delegate_perform(self.class, AndroidApp::PLATFORM_NAME, group.map(&:id))
      end
  end

end
