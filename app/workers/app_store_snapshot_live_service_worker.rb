class AppStoreSnapshotLiveServiceWorker
  include Sidekiq::Worker
  include AppStoreSnapshotServiceWorkerModule

  # accounting for retries ourself, so disable sidekiq retries
  sidekiq_options retry: false, queue: :sdk_live_scan
end
