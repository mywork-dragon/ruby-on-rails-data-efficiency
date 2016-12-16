class AppStoreSnapshotServiceWorker
  include Sidekiq::Worker
  include AppStoreSnapshotServiceWorkerModule

  # accounting for retries ourself, so disable sidekiq retries
  sidekiq_options retry: false, queue: :ios_web_scrape
end
