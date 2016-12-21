class AppStoreSnapshotLiveServiceWorker
  include Sidekiq::Worker
  include AppStoreSnapshotServiceWorkerModule

  sidekiq_options retry: false, queue: :ios_web_live_scrape
end
