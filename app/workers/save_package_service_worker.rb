class SavePackageServiceWorker

  include Sidekiq::Worker

  sidekiq_options queue: :sdk_scraper_queue

  include SavePackageWorker
  
end