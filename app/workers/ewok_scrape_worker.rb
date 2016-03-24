class EwokScrapeWorker
  include Sidekiq::Worker

  sidekiq_options retry: false, queue: :sdk_scraper_live_scan

  def perform(method, *args)
    self.send(method.to_sym, *args)
  end

  def scrape_ios(app_identifier)
    
  end

  def scrape_android(app_identifier)
  end
end