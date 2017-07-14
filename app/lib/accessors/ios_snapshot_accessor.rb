class IosSnapshotAccessor

  attr_reader :delegate

  def initialize
    # Change delegate type to swap out implementations
    @delegate = DiffSnapshotTableAccessor.new
  end

  def job_snapshots_count(ios_app_current_snapshot_job_id)
    @delegate.job_snapshots_count(ios_app_current_snapshot_job_id)
  end

  def mobile_priority_value(mobile_priority_symbol)
    @delegate.mobile_priority_value(mobile_priority_symbol)
  end

  def user_base_name(user_base_value)
    @delegate.user_base_name(user_base_value)
  end

  def column_type(column_name)
    @delegate.column_type(column_name)
  end

  def ios_app_ids_from_store_and_priority(app_store_id, mobile_priority_symbol)
    @delegate.ios_app_ids_from_store_and_priority(app_store_id, mobile_priority_symbol)
  end

  def ios_app_ids_from_user_base(user_base_value)
    @delegate.ios_app_ids_from_user_base(user_base_value)
  end

  def category_names_from_ios_app(ios_app)
    @delegate.category_names_from_ios_app(ios_app)
  end

  def user_base_details_from_ios_app(ios_app)
    @delegate.user_base_details_from_ios_app(ios_app)
  end

  def store_and_rating_details_from_ios_app(ios_app)
    @delegate.store_and_rating_details_from_ios_app(ios_app)
  end

  # Response type is a hash who's keys are the columns in the ios_app_current_snapshots
  # table along with the app_store key that refers to the AppStore ActiveRecord object
  # to which the snapshot belongs.
  def first_international_snapshot_hash_from_ios_app(ios_app, country_code: nil, user_bases: nil)
    @delegate.first_international_snapshot_hash_from_ios_app(ios_app, country_code: country_code, user_bases: user_bases)
  end

  def recently_released_ios_app_ids(lookback_time, ratings_min, app_store_id)
    @delegate.recently_released_ios_app_ids(lookback_time, ratings_min, app_store_id)
  end

  def recently_updated_snapshot_ids(limit: 5000, ratings_min: 0, app_store_id: 1, lookback_time: nil)
    @delegate.recently_updated_snapshot_ids(limit: limit, ratings_min: ratings_min, app_store_id: app_store_id, lookback_time: lookback_time)
  end

  def user_base_values_from_ios_app(ios_app)
    @delegate.user_base_values_from_ios_app(ios_app)
  end

  def app_store_details_from_ios_apps(ios_apps)
    @delegate.app_store_details_from_ios_apps(ios_apps)
  end

  def category_details_from_ios_apps(ios_apps)
    @delegate.category_details_from_ios_apps(ios_apps)
  end

  def categories_from_ios_app(ios_app)
    @delegate.categories_from_ios_app(ios_app)
  end

end
