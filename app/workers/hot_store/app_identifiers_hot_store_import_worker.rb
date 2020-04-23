class AppIdentifiersHotStoreImportWorker

  include Sidekiq::Worker
  include Utils::Workers

  sidekiq_options queue: :hot_store_application_import, retry: 2

  attr_reader :hs
  attr_reader :batch

  BATCH_SIZE = 1000

  def initialize
    @hs = AppIdentifierHotStore.new
  end

  def perform(platform, ids)
  end

  def import_map
    import_android_map
    import_ios_map
  end

  def import_android_map
    table = AndroidApp.table_name
    AndroidApp
      .relevant_since(HotStore::TIME_OF_RELEVANCE)
      .select("#{table}.app_identifier, #{table}.id")
      .find_in_batches(batch_size: BATCH_SIZE) do |group|
        delegate_perform(self.class, AndroidApp::PLATFORM_NAME, group.map(&:id))
      end
  end

  def import_ios_map
  end


end
