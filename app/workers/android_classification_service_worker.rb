class AndroidClassificationServiceWorker
  include Sidekiq::Worker
  include Utils::Workers
  include AndroidClassification

  sidekiq_options queue: :android_classification, retry: false
end
