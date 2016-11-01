class AndroidMassClassificationServiceWorker
  include Sidekiq::Worker
  include AndroidClassification

  sidekiq_options queue: :sdk, retry: false
end
