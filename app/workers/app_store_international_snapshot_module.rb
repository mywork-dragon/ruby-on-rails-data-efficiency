module AppStoreInternationalSnapshotModule

  class UnrecognizedFormat < RuntimeError
    def initialize(json)
      super(json.to_json)
    end
  end

  def perform(ios_app_current_snapshot_job_id, ios_app_ids, app_store_id)
    @ios_app_current_snapshot_job_id = ios_app_current_snapshot_job_id
    @ios_app_ids = ios_app_ids
    @app_store = AppStore.find(app_store_id)
    @s3_client = ItunesS3Store.new
    @bulk_store = AppStoreHelper::BulkStore.new(
      app_store_id: @app_store.id,
      ios_app_current_snapshot_job_id: @ios_app_current_snapshot_job_id,
      current_tables: @current_tables
    )
    get_and_store_apps
  end

  def get_and_store_apps
    ios_apps = IosApp.where(id: @ios_app_ids)
    ios_apps.each_slice(100) do |apps|
      identifier_to_app_map = apps.reduce({}) do |memo, app|
        memo[app.app_identifier] = app if app.app_identifier
        memo
      end
      res = ItunesApi.batch_lookup(identifier_to_app_map.keys, @app_store.country_code.downcase)
      res['results'].each { |app_json| add_app(app_json, identifier_to_app_map) }
    end
    bulk_save
  end

  def bulk_save
    @bulk_store.save
  end

  def add_app(app_json, identifier_to_app_map)
    extractor = AppStoreHelper::ExtractorJson.new(app_json)
    ios_app = identifier_to_app_map[extractor.app_identifier]
    extractor.verify_ios!
    @bulk_store.add_data(ios_app, app_json)
    @s3_client.store!(extractor.app_identifier, @app_store.country_code.downcase, :json, app_json.to_json)
  rescue AppStoreHelper::ExtractorJson::NotIosApp
    if ios_app
      ios_app.update!(
        display_type: IosApp.display_types[:not_ios],
        app_store_available: false
      )
    elsif extractor.alternate_identifier
      IosApp
        .find_by_app_identifier!(extractor.alternate_identifier)
        .update!(display_type: IosApp.display_types[:not_ios])
    else
      raise UnrecognizedFormat, app_json
    end
  end
end
