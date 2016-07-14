class ItunesChartWorker
  include Sidekiq::Worker
  
  # sidekiq_options queue: :aviato
  sidekiq_options queue: :sdk_live_scan

  def perform(method, *args)
    self.send(method.to_sym, *args)
  end

  def scrape_itunes_top_free
    ranked_app_identifiers = ItunesChartScraperService::FreeApps.new.ranked_app_identifiers

    existing_ios_apps = IosApp.where(app_identifier: ranked_app_identifiers)
    missing_app_identifiers = ranked_app_identifiers - existing_ios_apps.pluck(:app_identifier)
    new_ios_apps = create_ios_apps(missing_app_identifiers)
    store_free_app_ranks(ranked_app_identifiers)
    scrape_new_ios_apps(new_ios_apps)
    
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
        released: app_json['releaseDate']
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

    IosAppRanking.import rows

    ios_app_ranking_snapshot.is_valid = true
    ios_app_ranking_snapshot.save!
  end

  def scrape_new_ios_apps(ios_apps)
    ios_apps.each do |ios_app|
      web_scrape_ios_app(ios_app)
    end

    if Rails.env.production?
      IosEpfScanService.scan_new_itunes_apps(ios_apps.map(&:id))
    end
  end

  def web_scrape_ios_app(ios_app)
    ios_app_id = ios_app.id
    
    if Rails.env.production?
      AppStoreSnapshotLiveServiceWorker.perform_async(nil, ios_app_id)
    else
      AppStoreSnapshotLiveServiceWorker.new.perform(nil, ios_app_id)
    end
  end

  def self.test
    new.perform(:scrape_itunes_top_free)
  end

end
