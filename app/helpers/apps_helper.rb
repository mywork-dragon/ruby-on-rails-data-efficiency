module AppsHelper
  def select_top_apps_from(apps, limit)
    return [] unless apps.present?
    result = unsorted_apps(apps).sort_by! { |ua| ua['all_version_ratings_count'].to_i}.reverse
    result.first(limit)
  end

  def select_most_recent_app_from(apps)
    return [] unless apps.present?
    unsorted_apps(apps).max_by { |ua| latest_release_of(ua) }
  end

  def latest_release_of(app)
    if app['versions_history'].blank?
      app['current_version_release_date'].blank? ? DateTime.now.prev_year(100) : app['current_version_release_date']
    else
      release_dates = app['versions_history'].map { |v| v['released'] }
      release_dates.max
    end
  end

  def unsorted_apps(apps)
    apps_ids = apps.map{ |a| a['id'] }.sort
    return @unsorted_apps if @cached_ids == apps_ids
    @cached_ids = apps_ids
    @unsorted_apps = apps.map { |a| apps_hot_store.read(a['platform'], a['id']) }
  end

  def platform_icon(platform)
    platform == 'ios' ? 'fab fa-apple' : 'fab fa-android'
  end

end
