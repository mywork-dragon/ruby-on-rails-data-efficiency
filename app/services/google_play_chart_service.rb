class GooglePlayChartService

  class << self
    def run_gplay_top_free
      GooglePlayChartWorker.perform_async(:load_top_free)
      true
    end
  end
end
