class AndroidClassificationServiceWorker
  include Sidekiq::Worker
  include AndroidClassification

  sidekiq_options queue: :android_classification, retry: false
end
