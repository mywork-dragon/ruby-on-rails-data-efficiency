class ApkSnapshotServiceWorker

  include Sidekiq::Worker

  MAX_TRIES = 5

  sidekiq_options backtrace: true, retry: MAX_TRIES, queue: :sdk
  
end