# Module for Google Play Store Scraping
# Sidekiq Workers can require it
# worker must define "proxy_type" and "scrape_new_similar_apps" methods
module GooglePlaySnapshotModule
  class UnregisteredProxyType < RuntimeError; end
  class FailedLookup; end

  def perform(android_app_snapshot_job_id, android_app_id)
    @android_app_snapshot_job_id = android_app_snapshot_job_id
    @android_app = AndroidApp.find(android_app_id)

    b = Time.now
    result = generate_attributes
    puts "HTTP time: #{Time.now - b}"
    return if result == FailedLookup

    b = Time.now
    save_attributes
    puts "Save time: #{Time.now - b}"

    b = Time.now
    update_android_app_columns
    puts "update app time: #{Time.now - b}"
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
  rescue GooglePlay::NotFound
    @android_app.update!(display_type: :taken_down)
    FailedLookup
  rescue GooglePlay::Unavailable
    @android_app.update!(display_type: :foreign)
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
    if category = @attributes[:category]
      categories_snapshot_primary = AndroidAppCategoriesSnapshot.new
      categories_snapshot_primary.android_app_snapshot = @snapshot
      categories_snapshot_primary.android_app_category = AndroidAppCategory.find_or_create_by(name: category)
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

    if released = @attributes[:released]
      mobile_priority = if released > 2.months.ago
                          :high
                        elsif released > 4.months.ago
                          :medium
                        else
                          :low
                        end
      @android_app.mobile_priority = mobile_priority
    end

    @android_app.newest_android_app_snapshot = @snapshot

    @android_app.save!
  end

  def save_new_similar_apps
    @similar_apps = if similar_apps = @attributes[:similar_apps]
                      missing = similar_apps - AndroidApp.where(app_identifier: similar_apps).pluck(:app_identifier)
                      rows = missing.map { |ai| AndroidApp.new(app_identifier: ai) }
                      AndroidApp.import rows
                      AndroidApp.where(app_identifier: similar_apps)
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
