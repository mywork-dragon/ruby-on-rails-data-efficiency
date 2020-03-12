# Module for Google Play Store Scraping
# Sidekiq Workers can require it

# REFACTOR:  Most of this logic is duplicated in AppStoreSnapshotServiceWorkerModule

module GooglePlaySnapshotModule
  class UnregisteredProxyType < RuntimeError; end
  class FailedLookup < RuntimeError; end
  include Utils::Workers

  def take_snapshot(android_app_snapshot_job_id, android_app_id, options={})
    android_app = AndroidApp.find(android_app_id)
    snapshot_attributes = fetch_attributes_for(android_app, options)
    android_app = assign_attributes_to_app(android_app, snapshot_attributes)

    snapshot = build_new_snapshot(snapshot_attributes, android_app, android_app_snapshot_job_id)
    build_snapshot_category_assoc(snapshot_attributes, snapshot)
    android_app.newest_android_app_snapshot = snapshot

    if options[:create_developer]
      android_app.android_developer = obtain_android_developer(snapshot_attributes)
      delegate_perform(GooglePlayDevelopersWorker, :create_by_android_app_id, android_app.id)
    end

    android_app.save!

    similar_apps = create_new_similar_apps(snapshot_attributes)
    if options[:scrape_new_similar_apps]
      scrape_new_similar_apps(android_app_snapshot_job_id, similar_apps, options)
    end
    true
  rescue FailedLookup => e
    Bugsnag.notify(e)
    nil
  end

  private

  def scrape_new_similar_apps(android_app_snapshot_job_id, similar_apps, options)
    similar_apps.each do |android_app|
      delegate_perform(self.class, android_app_snapshot_job_id, android_app.id, options[:create_developer])
    end
  end

  def fetch_attributes_for(app,options)
    GooglePlayService.single_app_details(app.app_identifier)
  rescue RequestErrors::NotFound
    app.update!(display_type: :taken_down)
    raise FailedLookup, "App Not Found: #{app.id} | #{app.app_identifier}"
  end

  def build_new_snapshot(attributes, app, job_id)
    snapshot = AndroidAppSnapshot.new(
      android_app: app,
      android_app_snapshot_job_id: job_id
    )

    AndroidAppSnapshot::SNAPSHOT_ATTRIBUTES.each do |sca|
      value = attributes[sca]
      if value.present? && AndroidAppSnapshot.columns_hash[sca.to_s].type == :string  # if it's a string and is too big
        value = DbSanitizer.truncate_string(value)
      end
      snapshot.assign_attributes(sca => value)
    end

    if iapr = attributes[:in_app_purchases_range]
      snapshot.in_app_purchase_min = iapr.min
      snapshot.in_app_purchase_max = iapr.max
    end

    if downloads = attributes[:downloads]
      snapshot.downloads_min = downloads.min
      # handle when google play specifies lower bound like "100+"
      snapshot.downloads_max = downloads.max != downloads.min ? downloads.max : nil
    end

    if seller_email = attributes[:seller_email]
      begin
        FarmToTableLogger.new(app, seller_email).send!
      rescue => exception
        Bugsnag.notify(exception)
      end
    end

    snapshot
  end

  def build_snapshot_category_assoc(attributes, snapshot)
    if category_id = attributes[:category_id]
      categories_snapshot_primary = AndroidAppCategoriesSnapshot.new
      categories_snapshot_primary.kind = :primary
      categories_snapshot_primary.android_app_category = AndroidAppCategory.find_or_create_by(category_id: category_id)
      if categories_snapshot_primary.android_app_category.name.blank? && attributes[:category_name].present?
        categories_snapshot_primary.android_app_category.update!(:name => attributes[:category_name])
      end
      # assigns but doesn't save yet
      snapshot.association(:android_app_categories_snapshots).add_to_target(categories_snapshot_primary)
      categories_snapshot_primary
    end
  end

  def assign_attributes_to_app(app, attributes)
    if downloads = attributes[:downloads]
      user_base = if downloads.max >= 5e6
        :elite
      elsif downloads.max >= 500e3
        :strong
      elsif downloads.max >= 50e3
        :moderate
      else
        :weak
      end
      app.user_base = user_base
    end

    if attributes[:price].to_i > 0
      app.display_type = AndroidApp.display_types["paid"]
    else
      app.display_type = AndroidApp.display_types["normal"]
    end

    app
  end

  def obtain_android_developer(attributes)
    # Some of this logic is redundant with that in GooglePlayDevelopersWorker
    # In fact the GooglePlayDevelopersWorker flow can be phased out once website attribution is not longer required.
    if attributes[:developer_google_play_identifier].present?
      AndroidDeveloper.find_or_initialize_by(identifier: attributes[:developer_google_play_identifier])
    end
  end

  def create_new_similar_apps(attributes)
    if similar_apps = attributes[:similar_apps]
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
end
