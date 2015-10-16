class PackageSearchServiceWorker

  include Sidekiq::Worker

  sidekiq_options backtrace: true, :retry => 2, queue: :sdk_scraper_live_scan_queue

  def single_queue?
    true
  end

  include PackageSearchWorker

  
end