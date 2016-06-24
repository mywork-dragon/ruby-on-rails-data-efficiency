class AppStoreInternationalUserBaseWorker
  include Sidekiq::Worker
  
  sidekiq_options queue: :default, retry: false

  class MalformedData < RuntimeError; end
  class BackoffFailure < RuntimeError; end

  def perform(app_store_id)
    @app_store_id = app_store_id
    update_user_bases
  end

  def update_user_bases
    # go from weak to elite so we can use minimum metrics
    IosApp.user_bases.keys.reverse.each do |user_base|
      metrics = minimum_metrics(user_base.to_sym)
      update_snapshots(user_base.to_sym, metrics[:count], metrics[:rpd])
    end
  end

  # break into 2 queries to use range indices
  def update_snapshots(user_base, count, rpd)
    use_write_backoff do |_args = nil|
      IosAppCurrentSnapshotBackup
        .where(app_store_id: @app_store_id)
        .where('ratings_all_count >= ?', count)
        .update_all(user_base: IosApp.user_bases[user_base])
    end

    use_write_backoff do |_args = nil|
      IosAppCurrentSnapshotBackup
        .where(app_store_id: @app_store_id)
        .where('ratings_per_day_current_release >= ?', rpd)
        .update_all(user_base: IosApp.user_bases[user_base])
    end
  end

  # doing concurrent updates to table causes deadlock problems with locked rows
  def use_write_backoff
    attempts = 0
    backoff_times = [0, 1, 2, 4, 8, 16, 32]
    begin
      raise BackoffFailure if attempts >= backoff_times.count
      puts "Attempt: #{attempts}"
      yield
    rescue => e
      raise e unless deadlock_error?(e) || wait_error?(e)
      sleep backoff_times[attempts]
      attempts += 1
      retry
    end
  end

  def deadlock_error?(e)
    msg_regex = /Deadlock found when trying to get lock/i
    true if e.class == ActiveRecord::StatementInvalid && e.message.match(msg_regex)
  end

  def wait_error?(e)
    msg_regex = /Lock wait timeout exceeded/i
    true if e.class == ActiveRecord::StatementInvalid && e.message.match(msg_regex)
  end

  def minimum_metrics(user_base_type)
    @scale_factors = @scale_factors || AppStoreScalingFactorBackup.find_by!(@app_store_id)
    raise MalformedData unless @scale_factors.ratings_all_count && @scale_factors.ratings_per_day_current_release
    {
      count: lower_bounds[user_base_type][:count] * @scale_factors.ratings_all_count,
      rpd: lower_bounds[user_base_type][:rpd] * @scale_factors.ratings_per_day_current_release
    }
  end

  # defines lower bounds for metrics for US numbers
  def lower_bounds
    {
      weak: {
        count: 0,
        rpd: 0
      },
      moderate: {
        count: 100,
        rpd: 0.1
      },
      strong: {
        count: 10e3,
        rpd: 1
      },
      elite: {
        count: 50e3,
        rpd: 7
      }
    }
  end
end
