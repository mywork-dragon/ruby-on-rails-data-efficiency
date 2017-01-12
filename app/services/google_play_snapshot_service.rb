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

    def run(
      notes: "Full scrape #{Time.now.strftime("%m/%d/%Y")}",
      description: 'Run current Android apps',
      query: { display_type: AndroidApp.display_types.values_at(:normal, :foreign) }
      )
      # Scrape the GooglePlay store for android app info, by
      # default this function scrapes valid android apps. It
      # can also be called with an active record query which
      # determines which android apps to scan.

      check_dom
      initiate_proxy_spinup
      j = AndroidAppSnapshotJob.create!(notes: notes)
      batch = Sidekiq::Batch.new
      batch.description = description
      batch.on(
        :complete,
        'GooglePlaySnapshotService#on_complete',
        'last_android_app_id' => AndroidApp.last.id
      )

      batch.jobs do
          AndroidApp.where(query).pluck(:id).each_slice(1000) do |app_ids|
            args = app_ids.map {|app_id| [j.id, app_id]}
            SidekiqBatchQueueWorker.perform_async(
              GooglePlaySnapshotMassWorker.to_s,
              args,
              batch.bid
            )
        end
      end
    end

    def run_all(notes: "All app scrape")
      run(
        notes: notes,
        description: 'Run all Android apps',
        query: nil
      )
    end

    def run_ids(notes: 'Running by ids', android_app_ids: [])
      run(
        notes: notes,
        description: 'Run android apps by ids',
        query: { id: android_app_ids }
      )
    end
  end

  def on_complete(status, options)
    ProxyControl.stop_proxies
    last_android_app_id = options['last_android_app_id'].to_i
    Slackiq.notify(
      webhook_name: :main,
      status: status,
      title: 'Google Play scrape completed',
      'Apps Created' => AndroidApp.where('id > ?', last_android_app_id).count
    )
  end
end
