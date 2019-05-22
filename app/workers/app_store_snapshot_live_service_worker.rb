# Used in ItunesChartWorker

class AppStoreSnapshotLiveServiceWorker
  include Sidekiq::Worker
  include AppStoreSnapshotServiceWorkerModule

  sidekiq_options retry: false, queue: :live
end
