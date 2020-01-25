class GooglePlayChartService
  extend Utils::Workers

  class << self
    def run_gplay_top_free
      delegate_perform(GooglePlayChartWorker, :load_top_free)
      true
    end
  end
end
