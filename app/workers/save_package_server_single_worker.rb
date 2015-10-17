class SavePackageServiceSingleWorker

  include Sidekiq::Worker

  sidekiq_options queue: :sdk_live_scan

  include SavePackageWorker
  
end