class AppStoreInternationalSnapshotWorker
  include Sidekiq::Worker
  include AppStoreInternationalSnapshotModule
  
  sidekiq_options retry: 1, queue: :ios_international_scrape

  def initialize
    @current_tables = false
  end
end
