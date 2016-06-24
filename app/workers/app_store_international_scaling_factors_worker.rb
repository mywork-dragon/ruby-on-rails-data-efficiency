class AppStoreInternationalScalingFactorsWorker
  include Sidekiq::Worker
  
  sidekiq_options queue: :default, retry: false

  FACTOR_SAMPLE_SIZE = 100


  def perform(app_store_id)
    fill_scaling_factors(app_store_id)
  end

  def fill_scaling_factors(app_store_id)
    @app_store_id = app_store_id
    AppStoreScalingFactorBackup.create!(
      app_store_id: app_store_id,
      ratings_all_count: all_count_factor,
      ratings_per_day_current_release: per_day_current_release_factor
    )
  rescue ActiveRecord::RecordNotUnique
  end

  def column_scaling_factor(app_store_id, column)
    column_entries = IosAppCurrentSnapshotBackup.where(app_store_id: @app_store_id)
      .where.not(column => nil) 
      .order(column => :desc).limit(FACTOR_SAMPLE_SIZE).pluck(column)
    column_entries_us = IosAppCurrentSnapshotBackup.where(app_store_id: us_app_store.id)
      .where.not(column => nil) 
      .order(column => :desc).limit(FACTOR_SAMPLE_SIZE).pluck(column)
    return nil if column_entries.count == 0 || column_entries_us.count == 0
    avg = column_entries.sum.to_f / column_entries.count
    avg_us = column_entries_us.sum.to_f / column_entries_us.count
    avg / avg_us
  end

  def all_count_factor
    return 1.0 if is_us_app_store? 
    column_scaling_factor(@app_store_id, :ratings_all_count)
  end

  def per_day_current_release_factor
    return 1.0 if is_us_app_store?
    column_scaling_factor(@app_store_id, :ratings_per_day_current_release)
  end

  def us_app_store
    @us_app_store || @us_app_store = AppStore.find_by_country_code!('us')
  end

  def is_us_app_store?
    @app_store_id == us_app_store.id
  end
end
