class AppStoreSnapshotServiceWorker
  include Sidekiq::Worker
  include AppStoreSnapshotServiceWorkerModule

  # accounting for retries ourself, so disable sidekiq retries
  sidekiq_options retry: false, queue: :default
  MAX_TRIES = 3
  TRIGGER_FOLLOW_UPS = false
end
