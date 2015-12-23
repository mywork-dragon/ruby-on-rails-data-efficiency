class IosMassClassificationServiceWorker

  include Sidekiq::Worker

  include IosClassification

  sidekiq_options backtrace: true, queue: :ios_mass_scan_cloud

end