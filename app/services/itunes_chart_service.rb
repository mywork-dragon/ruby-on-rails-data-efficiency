class ItunesChartService
  class << self
    def run_itunes_top_free
      ItunesChartWorker.perform_async('scrape_itunes_top_free')
      true
    end
  end
end
