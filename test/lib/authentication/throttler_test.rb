require 'test_helper'
require 'mocks/redis_mock'

class ThrottlerTest < ActiveSupport::TestCase

  def configure(unique_id, count, period, options = {})
    throttler = Throttler.new(unique_id, count, period, options)
    throttler.store = RedisMock.new
    throttler
  end

  test 'throttle key format' do
    unique_id = 'asdfasdf'
    throttler = configure(unique_id, 1, 60)
    key = throttler.throttle_key
    parts = key.split(':')
    assert_equal 3, parts.count
    assert_equal 'varys-api-throttler', parts[0]
    assert_equal unique_id, parts[1]
    assert parts[2].to_i > 0
  end

  test 'throttle key gets prefixed when set' do
    unique = 'unique_key'
    throttler = configure(unique, 1, 60, { prefix: unique })
    assert /^#{unique}:/.match(throttler.throttle_key)
  end

  test 'increment increases the count' do
    throttler = configure('asdfasdf', 1, 60)
    throttler.increment
    assert_equal '1', throttler.store.get(throttler.throttle_key)
  end

  test 'throws exception when exceed limit' do
    throttler = configure('asdfasdf', 1, 60)
    throttler.increment
    assert_raises(Throttler::LimitExceeded) do
      throttler.increment
    end
  end

  test 'throttle status format' do
    count = 10
    period = 1.day
    requests = 5
    throttler = configure('asdfasdf', count, period)
    requests.times { throttler.increment }
    status = throttler.status
    assert_equal requests, status[:current]
    assert_equal count, status[:limit]
    assert_equal period.to_i, status[:period]
  end
end
