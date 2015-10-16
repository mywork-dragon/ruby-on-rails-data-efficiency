class SavePackageServiceSingleWorker

  include Sidekiq::Worker

  sidekiq_options queue: :sdk_scraper_live_scan_queue

  include SavePackageWorker
  
end