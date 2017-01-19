class GooglePlayChartScraperService
  class << self
    def scrape_google_play_top_free
      Slackiq.message('Starting GooglePlayChartScraperService.google_play_top_free_scrape', webhook_name: :background)
      client = Aws::ECS::Client.new
      resp = client.run_task({
        cluster: "spot",
        task_definition: "google_play_top_free_scrape",
      })
    end
  end
end
