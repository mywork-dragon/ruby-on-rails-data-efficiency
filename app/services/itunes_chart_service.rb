class ItunesChartService
  
  class << self

    def run_itunes_top_free
      batch = Sidekiq::Batch.new
      batch.description = "run_itunes_top_free #{Time.now.strftime("%m/%d/%Y")}"
      batch.on(:complete, "ItunesChartService#on_complete_run_itunes_top_free")
      batch.jobs do
        ItunesChartWorker.perform_async('scrape_itunes_top_free')
      end
      true
    end

  end

  def on_complete_run_itunes_top_free(status, options)
    Slackiq.notify(webhook_name: :main, status: status, title: "iTunes Top Free Apps Rankings Scrape Complete")
  end

end