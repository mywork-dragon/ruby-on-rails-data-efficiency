class AppStoreInternationalSnapshotWorker
  include Sidekiq::Worker
  include AppStoreInternationalSnapshotModule
  
  sidekiq_options retry: 1, queue: :ios_international_scrape

end
