module AppStoreHelper
  class BulkStore

    attr_reader :snapshots, :categories, :snapshots_to_categories, :category_map

    class InsertMismatch < RuntimeError; end

    def initialize(app_store_id:, ios_app_current_snapshot_job_id: nil, current_tables: false)
      @app_store_id = app_store_id
      @ios_app_current_snapshot_job_id = ios_app_current_snapshot_job_id
      @current_tables = current_tables
      setup_storage
      setup_tables
    end

    def setup_storage
      @snapshots = {}
      @categories = {}
      @snapshots_to_categories = {}
      @category_map = nil
    end

    def setup_tables
      @snapshot_table = @current_tables ? IosAppCurrentSnapshot : IosAppCurrentSnapshotBackup
      @category_join_table = @current_tables ? IosAppCategoriesCurrentSnapshot : IosAppCategoriesCurrentSnapshotBackup
      @category_name_table = @current_tables ? IosAppCategoryName : IosAppCategoryNameBackup
    end

    def add_data(ios_app, lookup_json, scrape_html = nil)
      json_attrs = AppStoreHelper::Extractor.new(lookup_json, type: :json)
      html_attrs = AppStoreHelper::Extractor.new(scrape_html, type: :html) if scrape_html

      populate_snapshots(ios_app, json_attrs, html_attrs)
      populate_categories(json_attrs)
      populate_snapshots_to_categories(ios_app, json_attrs)
    end

    def save
      generate_category_map
      snapshot_rows = bulk_store_snapshots(@snapshots.values)
      attribute_categories(snapshot_rows)
      attribute_to_store(snapshot_rows) if @current_tables
    end
    
    private 

    def attribute_to_store(snapshot_rows)
      app_store_join_rows = snapshot_rows.map do |snapshot|
        AppStoresIosApp.new(
          ios_app_id: snapshot.ios_app_id,
          app_store_id: @app_store_id
        )
      end

      AppStoresIosApp.import app_store_join_rows
    end

    def attribute_categories(snapshot_rows)
      category_join_rows = snapshot_rows.map do |snapshot|
        cats = @snapshots_to_categories[snapshot.ios_app_id]
        cats.map do |info|
          @category_join_table.new(
            ios_app_current_snapshot_id: snapshot.id,
            kind: @category_join_table.kinds[info[:kind]],
            ios_app_category_id: @category_map[info[:category_identifier]].id
          )
        end
      end.flatten
      # don't care about failures or output
      @category_join_table.import(category_join_rows)
    end

    def generate_category_map
      create_missing_categories
      create_missing_category_names
      @category_map = generate_lookup_map
    end

    def bulk_store_snapshots(snapshot_rows)
      insert_info = @snapshot_table.import(
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

    def conflict_id(row)
      snapshot_uniqueness_index_keys.map do |key|
        row.send(key)
      end.join(',')
    end

    def create_missing_categories
      category_ids = @categories.keys
      existing_categories = IosAppCategory.where(
        category_identifier: category_ids
      ).pluck(:category_identifier)
      missing_categories = category_ids - existing_categories
      missing_category_rows = missing_categories.map do |category_id|
        IosAppCategory.new(
          category_identifier: category_id,
          name: @categories[category_id]
        )
      end
      # do not care about collisions
      IosAppCategory.import missing_category_rows
    end

    def create_missing_category_names
      categories = IosAppCategory.where(
        category_identifier: @categories.keys
      )
      existing_names = @category_name_table.where(
        ios_app_category_id: categories.pluck(:id),
        app_store_id: @app_store_id
      ).pluck(:ios_app_category_id)

      missing_categories = categories.where.not(id: existing_names)
      missing_category_rows = missing_categories.map do |ios_app_category|
        category_identifier = ios_app_category.category_identifier
        @category_name_table.new(
          ios_app_category_id: ios_app_category.id,
          name: @categories[category_identifier],
          app_store_id: @app_store_id
        )
      end
      # do not care about collisions
      @category_name_table.import missing_category_rows
    end

    def generate_lookup_map
      map = IosAppCategory.where(
        category_identifier: @categories.keys
      ).reduce({}) do |memo, ios_app_category|
        memo[ios_app_category.category_identifier] = ios_app_category
        memo
      end
      unless map.keys.count == @categories.keys.count
        raise 'Unexpected incomplete number of categories'
      end
      map
    end

    def snapshot_uniqueness_index_keys
      [:ios_app_id, :app_store_id]
    end

    def populate_snapshots(ios_app, json_attrs, html_attrs = nil)
      snapshot_row = @snapshot_table.new(
        app_store_id: @app_store_id,
        ios_app_current_snapshot_job_id: @ios_app_current_snapshot_job_id,
        ios_app_id: ios_app.id
      )
      populate_snapshot_from_lookup(snapshot_row, json_attrs)
      populate_snapshot_from_scrape(snapshot_row, html_attrs) if html_attrs
      populate_calculated_columns(snapshot_row)

      @snapshots[ios_app.id] = snapshot_row
    end

    # ones that can be calculated directly from the snapshot (ie not user base)
    def populate_calculated_columns(snapshot_row)
      rpd = ratings_per_day_current_release(snapshot_row)
      snapshot_row.ratings_per_day_current_release = rpd
      snapshot_row.mobile_priority = mobile_priority(snapshot_row)
      snapshot_row.user_base = if @current_tables # current tables have scaling factors calculated
                                 user_base(snapshot_row)
                               else
                                 :weak # default set to weak. Will get updated later if viable
                               end
    end

    def user_base(snapshot_row)
      # possibly added a new country but haven't done scaling factors calc before
      return :weak unless AppStoreScalingFactor.find_by_app_store_id(@app_store_id)

      new_user_base = IosApp.user_bases.keys.find do |user_base|
        metrics = UserBaseService::Ios.minimum_metrics_for_store(@app_store_id, user_base.to_sym)
        true if snapshot_row.ratings_all_count >= metrics[:count] || snapshot_row.ratings_per_day_current_release >= metrics[:rpd]
      end

      new_user_base ? new_user_base.to_sym : :weak
    end

    def ratings_per_day_current_release(snapshot)
      days_ago = (Date.tomorrow - snapshot.released).to_i
      days_ago = 1 if days_ago < 1 # because of timezones...sometimes gets released next day
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
      @snapshot_table.mobile_priorities[value]
    end

    def populate_snapshot_from_lookup(snapshot_row, json_attrs)
      populate_snapshot_with_cols(
        snapshot_row,
        cols_from_json_attrs,
        json_attrs
      )
    end

    def populate_snapshot_from_scrape(snapshot_row, html_attrs)
      populate_snapshot_with_cols(
        snapshot_row,
        cols_from_html_attrs,
        html_attrs
      )
    end

    def populate_snapshot_with_cols(snapshot_row, cols, data_source)
      cols.each do |col|
        value = data_source.send(col)
        next if value.nil?
        if @snapshot_table.columns_hash[col].type == :string
          value = DbSanitizer.truncate_string(value)
        end
        snapshot_row.send("#{col}=", value)
      end
    end

    def populate_categories(json_attrs)
      category_names = json_attrs.category_names
      category_ids = json_attrs.category_ids

      @categories[category_ids[:primary]] = category_names[:primary]
      category_ids[:secondary].each_with_index do |category_id, index|
        @categories[category_id] = category_names[:secondary][index]
      end
    end

    def populate_snapshots_to_categories(ios_app, json_attrs)
      category_ids = json_attrs.category_ids
      @snapshots_to_categories[ios_app.id] = []
      @snapshots_to_categories[ios_app.id] << {
        category_identifier: category_ids[:primary],
        kind: :primary,
      }
      category_ids[:secondary].each do |category_id|
        @snapshots_to_categories[ios_app.id] << {
          category_identifier: category_id,
          kind: :secondary
        }
      end
    end

    def cols_from_json_attrs
      %w(
        app_identifier
        name
        description
        release_notes
        version
        price
        seller_url
        size
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
        seller_name
      )
    end

    def cols_from_html_attrs
      # abbreviated because everything else is covered
      %w(
        has_in_app_purchases
        app_link_urls
      )
    end

    def self.test
      json_str = File.open(File.join(Rails.root, 'uber.ignore.json')) {|f| f.read}
      ios_app = IosApp.find_by_app_identifier!(368677368)
      x = new(app_store_id: 1, ios_app_current_snapshot_job_id: 1)
      x.add_data(ios_app, json_str)
      x
    end

  end
end
