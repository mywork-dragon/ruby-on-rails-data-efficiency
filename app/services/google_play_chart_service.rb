class GooglePlayChartService

  class << self

    def run_gplay_top_free
      batch = Sidekiq::Batch.new
      batch.description = "run_gplay_top_free #{Time.now.strftime("%m/%d/%Y")}"
      batch.on(:complete, "GooglePlayChartService#on_complete_run_gplay_top_free")
      batch.jobs do
        GooglePlayChartWorker.perform_async(:load_top_free)
      end
      true
    end

  end

  def on_complete_run_gplay_top_free(status, options)
    Slackiq.notify(webhook_name: :main, status: status, title: "Google Play Top Free Apps Rankings Scrape Complete")
  end
end
