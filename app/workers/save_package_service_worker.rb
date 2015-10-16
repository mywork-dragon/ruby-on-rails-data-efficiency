class SavePackageServiceWorker

  include Sidekiq::Worker

  sidekiq_options queue: :sdk_scraper

  include SavePackageWorker
  
end