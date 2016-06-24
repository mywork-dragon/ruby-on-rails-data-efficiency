class AppStoreInternationalSnapshotWorker
  include Sidekiq::Worker
  
  sidekiq_options retry: 1, queue: :default

  MAX_APPS = 200

  def perform(ios_app_current_snapshot_job_id, ios_app_ids, app_store_id)
    fail TooManyIds if ios_app_ids.count > MAX_APPS
    @ios_app_current_snapshot_job_id = ios_app_current_snapshot_job_id
    @ios_app_ids = ios_app_ids
    @app_store = AppStore.find(app_store_id)
    get_and_store_apps
  end

  def get_and_store_apps
    @apps_attributes = lookup_attributes
    category_map = generate_category_map
    store_apps(category_map)
  end

  def snapshot_uniqueness_index_keys
    [:ios_app_id, :app_store_id]
  end

  def conflict_id(row)
    snapshot_uniqueness_index_keys.map do |key|
      row.send(key)
    end.join(',')
  end

  def bulk_store_snapshots(snapshot_rows)
    insert_info = IosAppCurrentSnapshotBackup.import(
      snapshot_rows,
      synchronize: snapshot_rows,
      synchronize_keys: snapshot_uniqueness_index_keys
    )
    failed_keys = insert_info[:failed_instances].map { |conflict_row| conflict_id(conflict_row) }
    new_rows = snapshot_rows.select do |row|
      true unless failed_keys.any? { |key| conflict_id(row) == key }
    end
    raise InsertMismatch unless new_rows.count == (snapshot_rows.count - failed_keys.count)
    new_rows
  end

  def bulk_store_category_attributions(rows)
    # don't care about failures or output
    IosAppCategoriesCurrentSnapshotBackup.import(rows)
  end

  def store_apps(category_map)
    valid_apps = IosApp.where(app_identifier: @apps_attributes[:attributes].keys)
    rows = valid_apps.map do |ios_app|
      app_attributes = @apps_attributes[:attributes][ios_app.app_identifier]
      build_snapshot_row(ios_app.id, app_attributes)
    end
    snapshots = bulk_store_snapshots(rows)
    rows = snapshots.map do |current_snapshot|
      attribute_categories(
        current_snapshot,
        @apps_attributes[:attributes][current_snapshot.app_identifier],
        category_map
      )
    end.flatten
    bulk_store_category_attributions(rows)
  end

  def attribute_categories(snapshot, app_attributes, category_map)
    rows = []
    primary = primary_category(app_attributes)
    ios_app_category_id = category_map[primary.keys.first].id
    rows << category_join(snapshot.id, ios_app_category_id, :primary)
    secondary_categories(app_attributes).each do |secondary|
      ios_app_category_id = category_map[secondary.keys.first].id
      rows << category_join(snapshot.id, ios_app_category_id, :secondary)
    end
    rows
  end

  def category_join(snapshot_id, ios_app_category_id, kind)
    IosAppCategoriesCurrentSnapshotBackup.new(
      ios_app_category_id: ios_app_category_id,
      ios_app_current_snapshot_id: snapshot_id,
      kind: IosAppCategoriesCurrentSnapshotBackup.kinds[kind]
    )
  end

  # ones that can be calculated directly from the snapshot (ie not user base)
  def populate_calculated_cols(ios_app_current_snapshot)
    rpd = ratings_per_day_current_release(ios_app_current_snapshot)
    ios_app_current_snapshot.ratings_per_day_current_release = rpd
    ios_app_current_snapshot.mobile_priority = mobile_priority(ios_app_current_snapshot)
  end

  def ratings_per_day_current_release(snapshot)
    days_ago = (Date.tomorrow - snapshot.released).to_i
    snapshot.ratings_current_count / (days_ago.to_f)
  end

  def mobile_priority(snapshot)
    released = snapshot.released
    value = if released > 2.months.ago
      :high
    elsif released > 4.months.ago
      :medium
    else
      :low
    end
    IosAppCurrentSnapshotBackup.mobile_priorities[value]
  end

  def build_snapshot_row(ios_app_id, app_attributes)
    snapshot = IosAppCurrentSnapshotBackup.new(
      ios_app_id: ios_app_id,
      app_store_id: @app_store.id,
      ios_app_current_snapshot_job_id: @ios_app_current_snapshot_job_id
    )
    populate_snapshot_columns(snapshot, app_attributes)
    populate_calculated_cols(snapshot)
    snapshot
  end

  def populate_snapshot_columns(snapshot, app_attributes)
    single_column_attributes.each do |col|
      value = app_attributes[col.to_sym]
      next unless value
      if IosAppCurrentSnapshotBackup.columns_hash[col].type == :string
        value = DbSanitizer.truncate_string(value)
      end
      snapshot.send("#{col}=", value)
    end
  end

  def lookup_attributes
    app_identifiers = IosApp.where(id: @ios_app_ids).pluck(:app_identifier).compact
    AppStoreService::BatchLookup.attributes(
      app_identifiers,
      country_code: @app_store.country_code
    )
  end

  def generate_category_map
    ids_to_names = extract_category_ids_mapping(@apps_attributes)
    create_missing_categories(ids_to_names)
    create_missing_category_names(ids_to_names)
    generate_lookup_map(ids_to_names.keys)
  end

  def generate_lookup_map(category_identifiers)
    map = IosAppCategory.where(
      category_identifier: category_identifiers
    ).reduce({}) do |memo, ios_app_category|
      memo[ios_app_category.category_identifier] = ios_app_category
      memo
    end
    unless map.keys.count == category_identifiers.count
      raise 'Unexpected incomplete number of categories'
    end
    map
  end

  # assumes all exist categories exist
  def create_missing_category_names(category_ids_to_names)
    categories = IosAppCategory.where(
      category_identifier: category_ids_to_names.keys
    )
    existing_names = IosAppCategoryNameBackup.where(
      ios_app_category_id: categories.pluck(:id),
      app_store_id: @app_store.id
    ).pluck(:ios_app_category_id)

    missing_categories = categories.where.not(id: existing_names)
    missing_categories.each do |ios_app_category|
      category_identifier = ios_app_category.category_identifier
      begin
        IosAppCategoryNameBackup.create!(
          ios_app_category_id: ios_app_category.id,
          name: category_ids_to_names[category_identifier],
          app_store_id: @app_store.id
        )
      rescue ActiveRecord::RecordNotUnique
      end
    end
  end

  def create_missing_categories(ids_to_category_names)
    category_ids = ids_to_category_names.keys
    existing_categories = IosAppCategory.where(
      category_identifier: category_ids
    ).pluck(:category_identifier)
    missing_categories = category_ids - existing_categories
    missing_categories.each do |category_id|
      begin
        IosAppCategory.create!(
          category_identifier: category_id,
          name: ids_to_category_names[category_id]
        )
      rescue ActiveRecord::RecordNotUnique
      end
    end
  end

  def extract_category_ids_mapping(apps_attributes)
    apps_attributes[:attributes].values.reduce({}) do |memo, attributes|
      extract_category_from_attributes(attributes).each do |category_id, name|
        memo[category_id] = name
      end
      memo
    end
  end
  
  def extract_category_from_attributes(attributes)
    categories = primary_category(attributes)
    secondary_categories(attributes).each do |info|
      categories.merge!(info)
    end
    categories
  end

  def primary_category(attributes)
    category_names = attributes[:categories]
    category_ids = attributes[:category_ids]
    {
      category_ids[:primary] => category_names[:primary]
    }
  end

  def secondary_categories(attributes)
    categories = []
    category_names = attributes[:categories]
    category_ids = attributes[:category_ids]
    category_ids[:secondary].each_with_index do |id, index|
      categories << {
        id => category_names[:secondary][index]
      }
    end
    categories
  end

  def invalidate(app_identifier:, app_store:, ios_app_current_snapshot_job_id:)
    ios_app = IosApp.find_by_app_identifier(app_identifier)
    return if ios_app.blank?

    s = IosAppCurrentSnapshot.where(app_store: app_store, ios_app: ios_app).last
    return if s.blank?

    s.set_columns_nil(@column_names_to_clear)
    s.valid = false
    s.ios_app_current_snapshot_job_id = ios_app_current_snapshot_job_id
    s.save!
  end

  def single_column_attributes
    %w(
      app_identifier
      name
      description
      release_notes
      version
      price
      seller_url
      size
      seller
      by
      developer_app_store_identifier
      recommended_age
      required_ios_version
      first_released
      screenshot_urls
      released
      ratings_current_stars
      ratings_current_count
      ratings_all_stars
      ratings_all_count
      icon_url_512x512
      icon_url_100x100
      icon_url_60x60
      game_center_enabled
      bundle_identifier
      currency
      screenshot_urls
    )
  end

  class << self  
  
    # For development
    def seed_app_stores
      file_contents = IO.read("db/app_store_countries.txt")

      lines = file_contents.split("\n").compact

      countries = []

      (0..(lines.count - 1)).step(2) do |n|
        h = {}
        h[:code] = lines[n].chomp
        h[:name] = lines[n + 1].chomp
        countries << h
      end

      countries.each do |country|
        as = AppStore.find_by_country_code(country[:code])
        if as.blank?
          AppStore.create!(country_code: country[:code], name: country[:name])
        end
      end

      countries
    end

    def seed_ios_apps_dev
      app_identifiers = [389801252, 2147483647, 368677368]  # Instagram, fake, Uber
      app_identifiers.each do |app_identifier|
        IosApp.find_or_create_by(app_identifier: app_identifier)
      end

      app_identifiers.map{ |ai| IosApp.find_by_app_identifier(ai) }
    end

    def seed_ios_apps_prod
      app_identifiers = [389801252, 368677368]  # Instagram, Uber
      app_identifiers.map{ |ai| IosApp.find_by_app_identifier(ai) }
    end


    def test(app_store_id = 146) # US by default
      if Rails.env.production?
        ios_app_ids = seed_ios_apps_prod
      else
        seed_app_stores
        ios_app_ids = seed_ios_apps_dev
      end

      AppStoreInternationalSnapshotWorker.new.perform(10, ios_app_ids, app_store_id)
    end

    def clear_backup_tables
      [
        IosAppCategoryNameBackup,
        IosAppCurrentSnapshotBackup,
        IosAppCategoriesCurrentSnapshotBackup,
        AppStoreIosAppsBackup,
        AppStoreScalingFactorBackup
      ].each {|x| reset_table(x) }
    end

    def reset_table(model_name)
      puts "Resetting #{model_name.to_s}: #{model_name.count} rows"
      model_name.delete_all
      ActiveRecord::Base.connection.execute("ALTER TABLE #{model_name.table_name} AUTO_INCREMENT = 1;")
    end
  
  end

  class TooManyIds < StandardError
    def initialize(message = "iTunes only allows a look up a max of #{MAX_APPS} apps")
      super
    end
  end
  class InsertMismatch < RuntimeError; end

  class DuplicateSnapshot; end
end
