class AppStoreInternationalBulkSnapshotWorker
  include Sidekiq::Worker
  
  sidekiq_options retry: 1, queue: :default

  def perform(ios_app_current_snapshot_job_id, app_identifiers)
    @ios_app_current_snapshot_job = IosAppCurrentSnapshotJob.find(ios_app_current_snapshot_job_id)
    ios_apps = IosApp.where(app_identifier: app_identifiers)
    AppStore.where(enabled: true).each do |app_store|
      @bulk_store = AppStoreHelper::BulkStore.new(
        app_store_id: app_store.id,
        ios_app_current_snapshot_job_id: ios_app_current_snapshot_job_id
      )
      ios_apps.each do |ios_app|
        extract_features_to_bulk_data(app_store, ios_app)
      end
      @bulk_store.save
    end
  end

  def extract_features_to_bulk_data(app_store, ios_app)
    key_path = AppStoreInternationalLambdaService.s3_key_path(
      @ios_app_current_snapshot_job,
      ios_app.app_identifier,
      app_store.country_code.downcase
    )
    content = MightyAws::S3.new.ios_scrape_content(
      bucket: AppStoreInternationalLambdaService.s3_bucket,
      key_path: key_path
    )
    @bulk_store.add_data(
      ios_app,
      content[:lookup_json_str],
      content[:scrape_html_str]
    )
  rescue MightyAws::S3::NoSuchKey
  end

  def self.test
    app_identifiers = [368677368, 401626263]
    app_identifiers.each do |app_identifier|
      IosApp.find_or_create_by(app_identifier: app_identifier)
    end

    IosAppCurrentSnapshotJob.find_or_create_by(id: 1)

    AppStoreInternationalTriggerWorker.new.perform(1, app_identifiers)
    puts "triggering and sleeping for 3 seconds to let finish"
    sleep 3
    puts "starting to pull content"

    new.perform(1, app_identifiers)
  end
end
