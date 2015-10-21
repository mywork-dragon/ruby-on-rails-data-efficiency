class SavePackageServiceWorker

  include Sidekiq::Worker

  sidekiq_options queue: :sdk

  include SavePackageWorker
  
end