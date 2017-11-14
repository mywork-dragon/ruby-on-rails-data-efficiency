# Module for Google Play Store Scraping
# Sidekiq Workers can require it
# worker must define "proxy_type" and "scrape_new_similar_apps" methods
module GooglePlaySnapshotModule
  class UnregisteredProxyType < RuntimeError; end
  class FailedLookup; end

  def perform(android_app_snapshot_job_id, android_app_id, create_developer = false)
    @android_app_snapshot_job_id = android_app_snapshot_job_id
    @android_app = AndroidApp.find(android_app_id)

    result = generate_attributes
    return if result == FailedLookup

    save_attributes

    update_android_app_columns
    update_android_developer_identifier

    if create_developer
      GooglePlayDevelopersWorker.perform_async(:create_by_android_app_id, android_app_id)
    end
    if Rails.env.production?
      save_new_similar_apps
      scrape_new_similar_apps(@similar_apps)
    end
  end

  def generate_attributes
    raise UnregisteredProxyType unless proxy_type.present?
    @attributes = GooglePlayService.attributes(
      @android_app.app_identifier,
      proxy_type: proxy_type
    )
  rescue GooglePlayStore::NotFound
    @android_app.update!(display_type: :taken_down)
    FailedLookup
  rescue GooglePlayStore::Unavailable
    @android_app.update!(display_type: :taken_down)
    FailedLookup
  end

  def save_attributes
    create_snapshot
    load_attributes_into_snapshot
    save_snapshot
    create_join_columns_for_snapshot
  end

  def create_snapshot
    @snapshot = AndroidAppSnapshot.new(
      android_app: @android_app,
      android_app_snapshot_job_id: @android_app_snapshot_job_id
    )
  end

  def save_snapshot
    @snapshot.save!
  end

  def load_attributes_into_snapshot
    single_column_attributes.each do |sca|
      value = @attributes[sca.to_sym]

      if value.present? && AndroidAppSnapshot.columns_hash[sca].type == :string  # if it's a string and is too big
        value = DbSanitizer.truncate_string(value)
      end

      @snapshot.send("#{sca}=", value)
    end

    if iapr = @attributes[:in_app_purchases_range]
      @snapshot.in_app_purchase_min = iapr.min
      @snapshot.in_app_purchase_max = iapr.max
    end

    if downloads = @attributes[:downloads]
      @snapshot.downloads_min = downloads.min
      @snapshot.downloads_max = downloads.max
    end
  end

  def create_join_columns_for_snapshot
    create_category_joins
    create_screenshot_joins
  end

  def create_category_joins
    if @attributes[:category_id]
      category_id = @attributes[:category_id]
      categories_snapshot_primary = AndroidAppCategoriesSnapshot.new
      categories_snapshot_primary.android_app_snapshot = @snapshot
      categories_snapshot_primary.android_app_category = AndroidAppCategory.find_or_create_by(category_id: category_id)
      if categories_snapshot_primary.android_app_category.name.nil? and @attributes[:category_name]
        categories_snapshot_primary.android_app_category.update!(:name => @attributes[:category_name])
      end
      categories_snapshot_primary.kind = :primary
      categories_snapshot_primary.save!
    end
  end

  def create_screenshot_joins
    if screenshot_urls = @attributes[:screenshot_urls]
      rows = screenshot_urls.map.with_index do |url, index|
        AndroidAppSnapshotsScrSht.new(
          url: url,
          position: index,
          android_app_snapshot_id: @snapshot.id
        )
      end

      AndroidAppSnapshotsScrSht.import rows
    end
  end

  def update_android_app_columns
    if downloads = @attributes[:downloads]
      user_base = if downloads.max >= 5e6
        :elite
      elsif downloads.max >= 500e3
        :strong
      elsif downloads.max >= 50e3
        :moderate
      else
        :weak
      end
      @android_app.user_base = user_base
    end

    @android_app.newest_android_app_snapshot = @snapshot

    @android_app.save!
  end

  def update_android_developer_identifier
    if @android_app.android_developer && @android_app.android_developer.identifier != @snapshot.developer_google_play_identifier
      developer = AndroidDeveloper.find_by_identifier(@snapshot.developer_google_play_identifier)
      # If a developer exists with this identifier it must've been created by a newer app.
      # we probably want to keep the oldest developer so we will assign the new developer's
      # apps to the older dev.
      if developer
        developer.identifier = nil
        developer.save!
        developer.android_apps.map do |app|
          app.android_developer = @android_app.android_developer
          app.save!
        end
      end
      @android_app.android_developer.update!(identifier: @snapshot.developer_google_play_identifier)
    end
  end

  def save_new_similar_apps
    @similar_apps = if similar_apps = @attributes[:similar_apps]
                      # bundle ids are case-sensitive but our table is case-insensitive...
                      # will miss apps until fixed
                      # https://github.com/MightySignal/varys/issues/745
                      existing = AndroidApp.where(app_identifier: similar_apps).pluck(:app_identifier)
                      missing = (similar_apps - existing).uniq
                      rows = missing.map { |ai| AndroidApp.new(app_identifier: ai, regions: []) }
                      AndroidApp.import rows
                      AndroidApp.where(app_identifier: missing)
                    else
                      []
                    end
  end

  def single_column_attributes
    %w(
      name
      description
      price
      seller
      seller_url
      released
      size
      top_dev
      required_android_version
      version
      content_rating
      ratings_all_stars
      ratings_all_count
      in_app_purchases
      icon_url_300x300
      developer_google_play_identifier
    )
  end
end
