module AppStoreInternationalSnapshotModule

  attr_writer :s3_client, :bulk_store

  class UnrecognizedFormat < RuntimeError
    def initialize(json)
      super(json.to_json)
    end
  end

  def perform(ios_app_current_snapshot_job_id, ios_app_ids, app_store_id)
    @ios_app_current_snapshot_job_id = ios_app_current_snapshot_job_id
    @ios_app_ids = ios_app_ids
    @app_store = AppStore.find(app_store_id)
    @s3_client ||= ItunesS3Store.new
    @bulk_store ||= AppStoreHelper::BulkStore.new(
      app_store_id: @app_store.id,
      ios_app_current_snapshot_job_id: @ios_app_current_snapshot_job_id
    )

    snapshot_job = IosAppCurrentSnapshotJob.where(id: ios_app_current_snapshot_job_id)
    @job_time = snapshot_job.empty? ? DateTime.now : snapshot_job.first.created_at
    @unchanged_app_ids = []

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
      disable_removed_apps(res['results'], identifier_to_app_map)
      res['results'].each { |app_json| add_app(app_json, identifier_to_app_map) }
    end
    bulk_save

    @bulk_store.snapshots.keys.each do |app_id|
      AppStoreDevelopersWorker.new.create_by_ios_app_id(app_id)
    end

    IosAppCurrentSnapshot.where(:id => @unchanged_app_ids).update_all(:last_scraped => @job_time)
  end

  def disable_removed_apps(results, identifier_to_app_map)
    returned_app_identifiers = results.map { |x| x['trackId'] }
    missing_app_identifiers = identifier_to_app_map.keys - returned_app_identifiers
    missing_ios_app_ids = missing_app_identifiers.map { |app_identifier| identifier_to_app_map[app_identifier].id }
    AppStoresIosApp.where(:app_store_id => @app_store.id).where(:ios_app_id => missing_ios_app_ids).destroy_all
  end

  def bulk_save
    @bulk_store.save
  end

  def add_app(app_json, identifier_to_app_map)
    extractor = AppStoreHelper::ExtractorJson.new(app_json)
    ios_app = identifier_to_app_map[extractor.app_identifier]
    extractor.verify_ios!

    # Offload S3 call to separate thread so we don't have to wait for response.
    Thread.new {
      @s3_client.store!(extractor.app_identifier, @app_store.country_code.downcase, :json, app_json.to_json)  
    }

    most_recent_snapshot = IosAppCurrentSnapshot.where(["ios_app_id = ? and app_store_id = ? and latest = ?", ios_app.id, @app_store.id, true]).first
    if most_recent_snapshot.nil? || most_recent_snapshot.etag.nil? || most_recent_snapshot.etag != extractor.etag
      @bulk_store.add_data(ios_app, app_json)
    else
      @unchanged_app_ids << most_recent_snapshot.id
    end
  rescue AppStoreHelper::ExtractorJson::NotIosApp
    if ios_app
      ios_app.update!(
        display_type: IosApp.display_types[:not_ios]
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
