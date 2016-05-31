class ItunesChartWorker
  include Sidekiq::Worker
  
  sidekiq_options queue: :aviato
  # sidekiq_options queue: :sdk_live_scan

  def perform(method, *args)
    self.send(method.to_sym, *args)
  end

  def scrape_itunes_top_free
    tries = 3
    begin
      app_identifiers = ItunesChartScraperService::FreeApps.scrape_apps
    rescue => e
      retry unless (tries -= 1).zero?
    end

    all_ios_apps = []
    new_ios_apps = []

    app_identifiers.each do |app_identifier|
      ios_app = IosApp.find_by_app_identifier(app_identifier)
      if ios_app.blank?
        ios_app = IosApp.create!(app_identifier: app_identifier)
        new_ios_apps << ios_app
      end

      all_ios_apps << ios_app
    end

    store_free_app_ranks(all_ios_apps)

    # scrape_new_ios_apps(new_ios_apps)
    
    true
  end

  private

  def store_free_app_ranks(ios_apps)
    ios_app_ranking_snapshot = IosAppRankingSnapshot.create!(kind: IosAppRankingSnapshot.kinds[:itunes_top_free])

    ios_apps.each_with_index do |ios_app, index|
      rank = index + 1  # Array is 0-indexed; rank is 1-indexed
      store_free_app_rank(ios_app: ios_app, ios_app_ranking_snapshot: ios_app_ranking_snapshot, rank: rank)
    end

    ios_app_ranking_snapshot.is_valid = true
    ios_app_ranking_snapshot.save!
  end

  def store_free_app_rank(ios_app:, ios_app_ranking_snapshot:, rank:)
    IosAppRanking.create!(rank: rank, ios_app: ios_app, ios_app_ranking_snapshot: ios_app_ranking_snapshot)
  end

  def scrape_new_ios_apps(ios_apps)
    tries = 3 # try 3 times
    ios_apps.each do |ios_app|
      begin
        scrape_ios_app(ios_app)
      rescue => e
        retry unless (tries -= 1).zero?
      end
    end
  end

  def scrape_ios_app(ios_app)
    ios_app_id = ios_app.id
    AppStoreSnapshotServiceWorker.new.perform(nil, ios_app_id)
    CreateDevelopersWorker.new.create_developers(ios_app_id, 'ios')
  end

end