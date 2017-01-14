class FbMauScrapeWorker
  include Sidekiq::Worker

  sidekiq_options retry: 2, queue: :fb_mau_scrape

  def perform(fb_app_id)
    data = FbGraphApi.lookup(fb_app_id)
    FbAppData.new(fb_app_id).store(data)
  end

  def on_complete(status, options)
    Slackiq.notify(webhook_name: :main, status: status, title: 'Scraped FB MAU data')
  end

  class << self

    def scrape_all
      batch = Sidekiq::Batch.new
      batch.description = 'Scrape all registered FB Apps'
      batch.on(:complete, 'FbMauScrapeWorker#on_complete')

      ids = IosApp.where.not(fb_app_id: nil).pluck(:fb_app_id).uniq

      batch.jobs do
        ids.each { |id| FbMauScrapeWorker.perform_async(id) }
      end

      puts 'Queued'
    end
  end
end
