class AndroidLiveClassificationServiceWorker
  include Sidekiq::Worker
  include AndroidClassification

  sidekiq_options queue: :sdk_live_scan, retry: false
end
