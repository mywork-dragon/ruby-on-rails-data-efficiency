class AppStoreInternationalLiveSnapshotWorker
  include Sidekiq::Worker
  include AppStoreInternationalSnapshotModule
  
  sidekiq_options retry: 1, queue: :ios_international_live_scrape

  def initialize
    @current_tables = true
  end
end
