module AppStoreHelper
  class BulkStore

    attr_reader :snapshots, :categories, :snapshots_to_categories, :category_map

    class InsertMismatch < RuntimeError; end
    class SnapshotsLockTimeout < RuntimeError; end

    def initialize(app_store_id:, ios_app_current_snapshot_job_id: nil)
      @app_store_id = app_store_id
      @ios_app_current_snapshot_job_id = ios_app_current_snapshot_job_id

      snapshot_job = IosAppCurrentSnapshotJob.where(id: ios_app_current_snapshot_job_id) 
      @job_time = snapshot_job.empty? ? DateTime.now : snapshot_job.first.created_at

      setup_storage
    end

    def setup_storage
      @snapshots = {}
      @categories = {}
      @snapshots_to_categories = {}
      @previous_snapshot_ids = []
      @category_map = nil
    end

    def add_data(ios_app, lookup_json, scrape_html = nil)
      json_attrs = AppStoreHelper::Extractor.new(lookup_json, type: :json)
      html_attrs = AppStoreHelper::Extractor.new(scrape_html, type: :html) if scrape_html

      populate_snapshots(ios_app, json_attrs, html_attrs)
      populate_categories(json_attrs)
      populate_snapshots_to_categories(ios_app, json_attrs)
      record_previous_snapshot_ids(ios_app)
    end

    def save
      generate_category_map
      snapshot_rows = bulk_store_snapshots(@snapshots.values)
      attribute_categories(snapshot_rows)
      attribute_to_store(snapshot_rows)
    end
    
    private 

    def record_previous_snapshot_ids(ios_app)
      @previous_snapshot_ids = @previous_snapshot_ids + IosAppCurrentSnapshot.where(["ios_app_id = ? and app_store_id = ? and latest = ?", ios_app.id, @app_store_id, true]).pluck(:id)
    end

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
          IosAppCategoriesCurrentSnapshot.new(
            ios_app_current_snapshot_id: snapshot.id,
            kind: IosAppCategoriesCurrentSnapshot.kinds[info[:kind]],
            ios_app_category_id: @category_map[info[:category_identifier]].id
          )
        end
      end.flatten
      # don't care about failures or output
      IosAppCategoriesCurrentSnapshot.import(category_join_rows)
    end

    def generate_category_map
      create_missing_categories
      create_missing_category_names
      @category_map = generate_lookup_map
    end

    def bulk_store_snapshots(snapshot_rows)
      lock_value = ActiveRecord::Base.connection.execute("SELECT GET_LOCK('ios_snapshots_worker_lock',45);").to_a
      raise SnapshotsLockTimeout unless lock_value[0][0] == 1
      
      ActiveRecord::Base.transaction do
        IosAppCurrentSnapshot
          .where(:id => @previous_snapshot_ids)
          .update_all(:latest => nil)

        insert_info = IosAppCurrentSnapshot.import!(
          snapshot_rows,
          synchronize: snapshot_rows,
          synchronize_keys: snapshot_uniqueness_index_keys
        )

        returned_ids = snapshot_rows.map(&:id).compact
        raise InsertMismatch unless returned_ids.length == snapshot_rows.length
      end
      snapshot_rows
    ensure
      ActiveRecord::Base.connection.execute("SELECT RELEASE_LOCK('ios_snapshots_worker_lock');")
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
      existing_names = IosAppCategoryName.where(
        ios_app_category_id: categories.pluck(:id),
        app_store_id: @app_store_id
      ).pluck(:ios_app_category_id)

      missing_categories = categories.where.not(id: existing_names)
      missing_category_rows = missing_categories.map do |ios_app_category|
        category_identifier = ios_app_category.category_identifier
        IosAppCategoryName.new(
          ios_app_category_id: ios_app_category.id,
          name: @categories[category_identifier],
          app_store_id: @app_store_id
        )
      end
      # do not care about collisions
      IosAppCategoryName.import missing_category_rows
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
      [:ios_app_id, :app_store_id, :latest]
    end

    def populate_snapshots(ios_app, json_attrs, html_attrs = nil)
      snapshot_row = IosAppCurrentSnapshot.new(
        app_store_id: @app_store_id,
        ios_app_current_snapshot_job_id: @ios_app_current_snapshot_job_id,
        ios_app_id: ios_app.id,
        latest: true,
        last_scraped: @job_time
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
      snapshot_row.user_base = user_base(snapshot_row)
    end

    def ratings_per_day_current_release(snapshot)
      days_ago = (Date.tomorrow - snapshot.released).to_i
      days_ago = 1 if days_ago < 1 # because of timezones...sometimes gets released next day
      snapshot.ratings_current_count / (days_ago.to_f)
    end

    # TODO: remove once the mobile_priority column is deleted.
    def mobile_priority(snapshot)
      released = snapshot.released
      value = if released > 2.months.ago
        0
      elsif released > 4.months.ago
        1
      else
        2
      end
    end

    def user_base(snapshot)
      IosAppCurrentSnapshot.user_bases.each do |user_base_name, user_base_value|
        minimum = UserBaseService::Ios.minimum_metrics_for_store(@app_store_id, user_base_name.to_sym)
        return user_base_value if snapshot.ratings_all_count >= minimum[:count] || snapshot.ratings_per_day_current_release >= minimum[:rpd]
      end
      IosAppCurrentSnapshot.user_bases[:weak]
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
        if IosSnapshotAccessor.new.column_type(col) == :string
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
        etag
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
