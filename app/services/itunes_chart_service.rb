class ItunesChartService

  class << self
    def run_itunes_top_free
      # This Worker scans the top free charts and enqueue the missing apps for scanning.
      ItunesChartWorker.perform_async('scrape_itunes_top_free')
      true
    end

    def get_storefront_charts(storefront_id)
      # This Worker scrapes all the categories pages, to build the charts.
      ItunesChartsRankingsWorker.perform_async(storefront_id) if storefront_id.present?
      true
    end
  end

end
