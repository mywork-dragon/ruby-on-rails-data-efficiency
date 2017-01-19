class GooglePlayChartWorker
  include Sidekiq::Worker
  
  sidekiq_options queue: :google_play_charts, retry: false

  attr_writer :s3_client

  class InvalidRankings < RuntimeError; end

  def perform(method, *args)
    send(method, *args)
  end

  def s3_client
    @s3_client ||= MightyAws::S3.new
    @s3_client
  end

  def load_top_free
    rankings = latest_rankings

    return Slackiq.message('No new Google Play top free scrape available', webhook_name: :main) if already_processed?(rankings)

    validate!(rankings)
    new_app_ids = extract_new_apps(rankings)

    if new_app_ids.present?
      scrape_app_metadata(new_app_ids)
      scrape_sdks(new_app_ids)
    end

    store_rankings(rankings)

    store_processed(rankings)
  end

  def processed_key_path(rankings)
    File.join('top_free', 'processed', Digest::SHA1.hexdigest(rankings.to_json))
  end

  def already_processed?(rankings)
    s3_client.retrieve(
      bucket: Rails.application.config.google_play_scrape_data,
      key_path: processed_key_path(rankings)
    )
    true
  rescue MightyAws::S3::NoSuchKey
    false
  end

  def latest_rankings
    JSON.parse(s3_client.retrieve(
      bucket: Rails.application.config.google_play_scrape_data,
      key_path: 'top_free/latest.json.gz'
    ))
  end

  def store_processed(rankings)
    s3_client.store(
      bucket: Rails.application.config.google_play_scrape_data,
      key_path: processed_key_path(rankings),
      data_str: ''
    )
  end

  def validate!(rankings)
    rankings_list = rankings['rankings'].keys
    raise InvalidRankings, "Expected >= 200 apps, got #{rankings_list.count}" if rankings_list.count < 200
  end

  def store_rankings(rankings)
    ranking_snapshot = AndroidAppRankingSnapshot.create!(
      kind: :top_free,
      is_valid: false
    )
    rows = rankings['rankings'].keys.map do |app_identifier|
      app = AndroidApp.find_by_app_identifier!(app_identifier)
      AndroidAppRanking.new(
        rank: rankings['rankings'][app_identifier]['rank'],
        android_app_id: app.id,
        android_app_ranking_snapshot_id: ranking_snapshot.id
      )
    end

    AndroidAppRanking.import rows

    ranking_snapshot.update!(is_valid: true)
  end

  def extract_new_apps(rankings)
    identifiers = rankings['rankings'].keys
    missing = identifiers - AndroidApp.where(app_identifier: identifiers).pluck(:app_identifier)
    missing.map do |app_identifier|
      AndroidApp.create!(app_identifier: app_identifier).id
    end
  end

  def scrape_app_metadata(android_app_ids)
    batch = Sidekiq::Batch.new
    batch.description = 'Live scraping GPlay apps for Top 200 chart'
    batch.on(
      :complete,
      'GooglePlayChartWorker#on_complete_metadata_scrape',
      'android_app_ids' => android_app_ids
    )

    batch.jobs do
      GooglePlaySnapshotLiveWorker.live_scrape_apps(android_app_ids)
    end
  end

  # relies on mass scan service to auto-classify
  def scrape_sdks(android_app_ids)
    AndroidMassScanService.run_by_ids(android_app_ids)
  end

  def update_developers(android_app_ids)
    android_app_ids.each do |id|
      GooglePlayDevelopersWorker.new.create_by_android_app_id(id)
    end
  end

  def on_complete_metadata_scrape(status, options)
    android_app_ids = options['android_app_ids'].map(&:to_i)
    update_developers(android_app_ids)
  end
  
end
