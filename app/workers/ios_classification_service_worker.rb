class IosClassificationServiceWorker

  include Sidekiq::Worker

  include IosClassification

  sidekiq_options backtrace: true, retry: false, queue: :ios_live_scan_cloud

end