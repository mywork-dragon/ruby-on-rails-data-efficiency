class GooglePlaySnapshotService
  class InvalidDom < RuntimeError; end

  class << self
    def check_dom
      raise InvalidDom unless GooglePlayService.dom_valid?
    end

    def initiate_proxy_spinup
      Slackiq.message('Starting temporary proxies', webhook_name: :main)
      ProxyControl.start_proxies
    end

    def run(notes: "Full scrape #{Time.now.strftime("%m/%d/%Y")}")
      check_dom
      initiate_proxy_spinup
      j = AndroidAppSnapshotJob.create!(notes: notes)
      batch = Sidekiq::Batch.new
      batch.description = 'Run current Android apps'
      batch.on(:complete, 'GooglePlaySnapshotService#on_complete')

      batch.jobs do
        GooglePlaySnapshotQueueWorker.perform_async(:queue_valid, j.id)
      end
    end

    def run_all(notes: "All app scrape")
      check_dom
      initiate_proxy_spinup
      j = AndroidAppSnapshotJob.create!(notes: notes)
      batch = Sidekiq::Batch.new
      batch.description = 'Run all Android apps'
      batch.on(:complete, 'GooglePlaySnapshotService#on_complete')

      batch.jobs do
        GooglePlaySnapshotQueueWorker.perform_async(:queue_all, j.id)
      end
    end

    def run_ids(notes: 'Running by ids', android_app_ids: [])
      check_dom
      initiate_proxy_spinup
      j = AndroidAppSnapshotJob.create!(notes: notes)
      batch = Sidekiq::Batch.new
      batch.description = 'Run android apps by ids'
      batch.on(:complete, 'GooglePlaySnapshotService#on_complete')

      batch.jobs do
        GooglePlaySnapshotQueueWorker.perform_async(:queue_ids, j.id, android_app_ids)
      end
    end
  end

  def on_complete(status, options)
    # ProxyControl.stop_proxies
    Slackiq.notify(webhook_name: :main, status: status, title: 'Google Play scrape completed')
  end
end
