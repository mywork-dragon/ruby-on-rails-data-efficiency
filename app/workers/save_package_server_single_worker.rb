class SavePackageServiceSingleWorker

  include Sidekiq::Worker

  sidekiq_options queue: :sdk_scraper_live_scan

  include SavePackageWorker
  
end