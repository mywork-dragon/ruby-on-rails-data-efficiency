class IosMassClassificationServiceWorker

  include Sidekiq::Worker

  include IosClassification

  sidekiq_options backtrace: true, retry: false, queue: :ios_mass_classification

end
