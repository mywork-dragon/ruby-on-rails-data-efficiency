class Throttler

  class LimitExceeded < RuntimeError; end

  attr_writer :store
  # unique_id: unique identifier
  # count: max number of requests per period (positive integer)
  # period: duration of request window in seconds (positive integer or object with to_i method)
  def initialize(unique_id, count, period, options={})
    @unique_id = unique_id
    @count = count.to_i
    @period = period.to_i
    @options = options
  end

  def store
    return @store if @store
    @store = Redis.new(host: ENV['VARYS_REDIS_URL'], port: ENV['VARYS_REDIS_PORT'])
    @store
  end

  def throttle_key
    prefix = @options[:prefix] || 'varys-api-throttler'
    t = Time.now.to_i
    "#{prefix}:#{@unique_id}:#{t/@period}"
  end

  def increment
    key = throttle_key
    result = store.incr(key)
    store.expire(key, @period)
    validate!(result)
  end

  def status
    current = store.get(throttle_key) || 0
    {
      current: current.to_i,
      limit: @count,
      period: @period
    }
  end

  def validate!(count)
    raise LimitExceeded if count > @count
  end
end
