class ItunesChartWorker
  include Sidekiq::Worker
  
  sidekiq_options queue: :itunes_charts, retry: 5

  def perform(method, *args)
    self.send(method.to_sym, *args)
  end

  def scrape_itunes_top_free
    ranked_app_identifiers = ItunesChartScraperService::FreeApps.new.ranked_app_identifiers
    if ranked_app_identifiers.empty
      raise "Empty ranked_app_identifiers set"
    end
    existing_ios_apps = IosApp.where(app_identifier: ranked_app_identifiers)
    missing_app_identifiers = ranked_app_identifiers - existing_ios_apps.pluck(:app_identifier)

    if missing_app_identifiers.present?
      new_ios_apps = create_ios_apps(missing_app_identifiers)
      scrape_new_ios_apps(new_ios_apps)
    end

    store_free_app_ranks(ranked_app_identifiers)
    
    true
  end

  private

  def create_ios_apps(app_identifiers)
    app_jsons = app_identifiers.each_slice(100).map do |partition|
      lookup_json = ItunesApi.batch_lookup(partition)
      lookup_json['results']
    end.flatten

    rows = app_jsons.map do |app_json|
      IosApp.new(
        app_identifier: app_json['trackId'],
        released: app_json['releaseDate'],
        source: :itunes_top_200
      )
    end

    IosApp.import(
      rows,
      synchronize: rows,
      synchronize_keys: [:app_identifier]
    )
    rows
  end

  def store_free_app_ranks(ranked_app_identifiers)
    ios_app_ranking_snapshot = IosAppRankingSnapshot.create!(kind: IosAppRankingSnapshot.kinds[:itunes_top_free])
    rows = ranked_app_identifiers.each_with_index.map do |app_identifier, index|
      ios_app = IosApp.find_by_app_identifier!(app_identifier)
      rank = index + 1 # 1-indexed
      IosAppRanking.new(
        rank: rank,
        ios_app: ios_app,
        ios_app_ranking_snapshot: ios_app_ranking_snapshot
      )
    end

    IosAppRanking.import(
      rows,
      synchronize: rows,
      synchronize_keys: [:ios_app_ranking_snapshot_id, :ios_app_id]
    )

    rows.map(&:log_activity)

    ios_app_ranking_snapshot.is_valid = true
    ios_app_ranking_snapshot.save!
  end

  def scrape_new_ios_apps(ios_apps)
    ios_app_ids = ios_apps.map(&:id)

    batch = Sidekiq::Batch.new
    batch.description = 'iTunes top 200 free intl scrape'
    batch.on(
      :complete,
      'ItunesChartWorker#on_complete_intl_scrape',
      'ios_app_ids' => ios_app_ids
    )
    batch.jobs do
      AppStoreInternationalService.scrape_ios_apps(ios_app_ids, live: true)
    end

    # TODO: make this better. Make sure intl scrapes complete before epf scan service runs
    ios_apps.each do |ios_app|
      us_scrape_ios_app(ios_app)
    end
    IosEpfScanService.scan_new_itunes_apps(ios_app_ids)
  end

  def us_scrape_ios_app(ios_app)
    ios_app_id = ios_app.id
    
    if Rails.env.production?
      AppStoreSnapshotLiveServiceWorker.perform_async(nil, ios_app_id)
    else
      AppStoreSnapshotLiveServiceWorker.new.perform(nil, ios_app_id)
    end
  end

  def on_complete_intl_scrape(status, options)
    ios_app_ids = options['ios_app_ids'].map(&:to_i)
    ios_app_ids.each do |ios_app_id|
      AppStoreDevelopersWorker.perform_async(:create_by_ios_app_id, ios_app_id)
    end
  end
end
