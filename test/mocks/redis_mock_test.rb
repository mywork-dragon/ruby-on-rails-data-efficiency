require 'test_helper'
require 'mocks/redis_mock'

class RedisMockTest < ActiveSupport::TestCase

  def setup
    @redis = RedisMock.new
  end

  test 'can get and set keys' do
    key = 'hello'
    @redis.set(key, 5)
    assert_equal '5', @redis.get(key)
  end

  test 'can increment existing key' do
    key = 'hello'
    @redis.set(key, 5)
    @redis.incr(key)
    assert_equal '6', @redis.get(key)
  end

  test 'can increment non existing key' do
    key = 'hello'
    @redis.incr(key)
    assert_equal '1', @redis.get(key)
  end

  test 'expire on non-existing key fails' do
    assert_equal false, @redis.expire('nope', 10)
  end

  test 'expire on existing key sets the value' do
    key = 'hello'
    @redis.set(key, 5)
    @redis.expire(key, 30)
    assert @redis.store[key][:expire].present?
  end

  test 'expiration works' do
    key = 'hello'
    previous_time = Time.now - 30
    Time.stub :now, previous_time do
      @redis.set(key, 5)
      @redis.expire(key, 5)
    end
    assert_nil @redis.get(key)
  end

  test 'multi' do
    @redis.incr('asdf')
    res = @redis.multi do
      @redis.set('hello', 5)
      @redis.incr('asdf')
    end
    assert_equal ['OK', 2], res
    assert_equal '5', @redis.get('hello')
  end

  test 'response stack' do
    @redis.incr('asdf')
    @redis.incr('asdf')
    @redis.incr('asdf')
    @redis.get('asdf')
    @redis.expire('asdf', 10)
    assert_equal [1, 2, 3, '3', true], @redis.response_stack
  end
end
