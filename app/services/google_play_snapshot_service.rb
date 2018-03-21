class GooglePlaySnapshotService
  class InvalidDom < RuntimeError; end

  class << self

    def initiate_proxy_spinup
      Slackiq.message('Starting temporary proxies', webhook_name: :main)
      ProxyControl.start_proxies
    end

    def start_scrape_from_newcomer_rankings
      page_size = 1000

      rankings_accessor = RankingsAccessor.new

      count_result = rankings_accessor.unique_newcomers(platform: "android", lookback_time: 1.days.ago, page_size: page_size, page_num: 1, count: true)
      num_pages = (count_result / page_size) + 1

      j = AndroidAppSnapshotJob.create!(notes: "Scrape from Newcomer Rankings #{Time.now.strftime("%m/%d/%Y")}")

      (1..num_pages).each do |page_num|
        page_result = rankings_accessor.unique_newcomers(platform: "android", lookback_time: 1.days.ago, page_size: page_size, page_num: page_num)
        newcomer_app_identifiers = page_result.map { |row| row["app_identifier"] }
        existing = AndroidApp.where(app_identifier: newcomer_app_identifiers).pluck(:app_identifier)
        missing = newcomer_app_identifiers - existing
        new_app_rows = missing.map { |ai| AndroidApp.new(app_identifier: ai, regions: []) }

        AndroidApp.import(
          new_app_rows,
          synchronize: new_app_rows,
          synchronize_keys: [:app_identifier]
        )

        new_app_rows.map(&:id).compact.each do |app_id|
          GooglePlaySnapshotMassWorker.perform_async(j.id, app_id)
        end
      end
    end

    def start_scrape(
      notes: "Full scrape #{Time.now.strftime("%m/%d/%Y")}",
      description: 'Run current Android apps',
      query: {}
      )
      # Scrape the GooglePlay store for android app info, by
      # default this function scrapes valid android apps. It
      # can also be called with an active record query which
      # determines which android apps to scan.

      j = AndroidAppSnapshotJob.create!(notes: notes)

      AndroidApp.where(query).pluck(:id).each do |app_id|
        GooglePlaySnapshotMassWorker.perform_async(j.id, app_id)
      end
    end

    def run(
      notes: "Full scrape #{Time.now.strftime("%m/%d/%Y")}",
      description: 'Run current Android apps',
      query: {}
      )
      # Scrape the GooglePlay store for android app info, by
      # default this function scrapes valid android apps. It
      # can also be called with an active record query which
      # determines which android apps to scan.

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
