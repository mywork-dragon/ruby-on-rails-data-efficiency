class DiffSnapshotTableAccessor

  def job_snapshots_count(ios_app_current_snapshot_job_id)
    IosAppCurrentSnapshot
      .where(ios_app_current_snapshot_job_id: ios_app_current_snapshot_job_id)
      .count
  end

  def column_type(column_name)
    IosAppCurrentSnapshot.columns_hash[column_name].type
  end

  def user_base_name(user_base_value)
    IosAppCurrentSnapshot.user_bases.key(user_base_value)
  end

  def ios_app_ids_from_user_base(user_base_value)
    IosAppCurrentSnapshot.where(user_base: user_base_value, latest: true).pluck(:ios_app_id).uniq
  end

  def category_names_from_ios_app(ios_app)
    ios_app.ios_app_current_snapshots.where(latest: true).joins(:ios_app_categories).pluck("ios_app_categories.name").uniq
  end

  def categories_from_ios_app(ios_app, with_category_id: false)
    (ios_app.ios_app_current_snapshots.where(latest: true).flat_map do |snap|
      snap.ios_app_categories_current_snapshots.map do |cat_snap|
          cat_details = { "name" => cat_snap.ios_app_category[:name], "type" => cat_snap.kind }
          cat_details["id"] = cat_snap.ios_app_category[:category_identifier] if with_category_id
          cat_details
      end
    end).uniq
  end

  def user_base_details_from_ios_app(ios_app)
    if ios_app.ios_app_current_snapshots.where(latest: true).any?
      ios_app.ios_app_current_snapshots
        .where(latest: true)
        .joins(:app_store)
        .select('app_stores.country_code, app_stores.name, user_base')
        .map{|app| {country_code: app.country_code, user_base: app.user_base, country: app.name} }
    else
      [{country_code: 'US', user_base: ios_app.user_base, country: 'United States'}]
    end
  end

  def store_and_rating_details_from_ios_app(ios_app, include_current: false)
    if ios_app.ios_app_current_snapshots.where(latest: true).any?
      if include_current
        snapshots_result = ios_app.ios_app_current_snapshots.where(latest: true).joins(:app_store).select('app_stores.country_code, app_stores.name, ratings_all_stars, ratings_all_count, ratings_current_stars, ratings_current_count, ratings_per_day_current_release')
        snapshots_result.map { |app| 
          {
            current_rating: app.ratings_current_stars,
            ratings_current_count: app.ratings_current_count,
            ratings_per_day_current_release: app.ratings_per_day_current_release,
            country_code: app.country_code,
            rating: app.ratings_all_stars,
            ratings_count: app.ratings_all_count,
            country: app.name
          }
        }
      else
        return ios_app.ios_app_current_snapshots.where(latest: true).joins(:app_store).select('app_stores.country_code, app_stores.name, ratings_all_stars, ratings_all_count').map{|app| {country_code: app.country_code, rating: app.ratings_all_stars, ratings_count: app.ratings_all_count, country: app.name}}
      end
    else
      if include_current
        return [{
          current_rating: ios_app.newest_ios_app_snapshot.try(:ratings_current_stars),
          ratings_current_count: ios_app.newest_ios_app_snapshot.try(:ratings_current_count),
          ratings_per_day_current_release: ios_app.newest_ios_app_snapshot.try(:ratings_per_day_current_release),
          country_code: 'US',
          rating: ios_app.newest_ios_app_snapshot.try(:ratings_all_stars),
          ratings_count: ios_app.newest_ios_app_snapshot.try(:ratings_all_count),
          country: 'United States'
        }]  
      else
        return [{country_code: 'US', rating: ios_app.newest_ios_app_snapshot.try(:ratings_all_stars), ratings_count: ios_app.newest_ios_app_snapshot.try(:ratings_all_count), country: 'United States'}]  
      end
    end
  end

  def first_international_snapshot_hash_from_ios_app(ios_app, country_code: nil, user_bases: nil)
    order_string = "display_priority IS NULL, display_priority ASC"

    snapshot = ios_app.ios_app_current_snapshots.where(latest: true).joins(:app_store)
    if user_bases.present?
      mapped_user_bases = user_bases.map{|user_base| IosApp.user_bases[user_base]}
      order_string = "user_base ASC, #{order_string}"
      userbase_snapshot = snapshot.where(user_base: mapped_user_bases)
      snapshot = userbase_snapshot if userbase_snapshot.any?
    end
    snapshot = snapshot.where('app_stores.country_code = ?', country_code) if country_code
    snapshot = snapshot.order(order_string).first

    return {} if snapshot.nil?

    snapshot_hash = snapshot.as_json
    snapshot_hash['app_store'] = snapshot.try(:app_store)
    snapshot_hash['categories_snapshots'] = snapshot.ios_app_categories_current_snapshots
    snapshot_hash
  end

  def recently_released_ios_app_ids(lookback_time, ratings_min, app_store_id)
    IosApp.joins(:ios_app_current_snapshots)
        .where('ios_apps.released > ?', lookback_time)
        .where('ios_app_current_snapshots.latest = ?', true)
        .where('ios_app_current_snapshots.app_store_id = ?', app_store_id)
        .where('ios_app_current_snapshots.ratings_all_count > ?', ratings_min)
        .pluck(:id)
  end

  def recently_updated_snapshot_ids(limit: 5000, ratings_min: 0, app_store_id: 1, lookback_time: nil)
    lookback_time ||= 2.weeks.ago
    IosAppCurrentSnapshot
        .where(latest: true)
        .where(app_store_id: app_store_id)
        .where('released > ?', lookback_time)
        .where('ratings_all_count > ?', ratings_min)
        .limit(limit).pluck(:ios_app_id)
  end

  def user_base_values_from_ios_app(ios_app)
    AppStore.enabled.order("display_priority IS NULL, display_priority ASC")
        .joins(:ios_app_current_snapshots)
        .where('ios_app_current_snapshots.ios_app_id' => ios_app.id)
        .where('ios_app_current_snapshots.latest' => true)
        .pluck('user_base')
  end

  def app_store_details_from_ios_apps(ios_apps)
    fields = ['ios_app_id', 'ios_app_current_snapshots.name', 'ratings_all_count', 'app_stores.country_code', 'app_stores.name', 'seller_name',
                'seller_url', 'user_base', 'price', 'first_released', 'released']
    IosAppCurrentSnapshot.joins(:app_store)
        .where(ios_app_id: ios_apps.map(&:id))
        .where('ios_app_current_snapshots.latest' => true)
        .order("ios_app_id, display_priority IS NULL, display_priority ASC")
        .pluck(*fields)
  end

  def category_details_from_ios_apps(ios_apps)
    IosAppCategory.joins(:ios_app_current_snapshots).where(
      'ios_app_current_snapshots.ios_app_id' => ios_apps.map(&:id), 
      'ios_app_current_snapshots.latest' => true, 
      'ios_app_categories_current_snapshots.kind' => 0).pluck('ios_app_current_snapshots.ios_app_id', 'ios_app_categories.name')
  end

  def app_ids_with_latest_snapshot(ios_app_ids)
    IosAppCurrentSnapshot.where(:ios_app_id => ios_app_ids).where(:latest => true).pluck(:ios_app_id)
  end

end
