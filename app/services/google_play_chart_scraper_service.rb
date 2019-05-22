# Called from DAG
# google_play_top_free_scrape seems to be defined in ECS by the google_play_scrape repo
# and contains two containers:
# 1. google_play_scraper
# 2. Selenium
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
