class FbMauScrapeWorker
  include Sidekiq::Worker

  sidekiq_options retry: false, queue: :fb_mau_scrape

  def perform(fb_app_id)
    data = FbGraphApi.lookup(fb_app_id)
    FbAppData.new(fb_app_id).store(data)
  end

  class << self

    def scrape_all
      ids = IosApp.where.not(fb_app_id: nil).pluck(:fb_app_id).uniq
      ids.each { |id| FbMauScrapeWorker.perform_async(id) }
    end
  end
end
