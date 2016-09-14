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
      j = AndroidAppSnapshotJob.create!(notes: notes)

      Slackiq.message('Starting to queue Google Play apps...', webhook_name: :main)

      AndroidApp.find_each.with_index do |android_app, index|
        li "App ##{index}" if index%10000 == 0
        GooglePlaySnapshotServiceWorker.perform_async(j.id, android_app.id)
      end

      Slackiq.message("Done queueing Google Play apps", webhook_name: :main)

    end

    def run_ids(notes: nil, android_app_ids)
    end
  end

  def on_complete(status, options)
  end
end
