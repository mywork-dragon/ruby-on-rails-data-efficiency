# https://redis.io/
class RedisMock
  include ActiveSupport::Callbacks

  define_callbacks :expire_keys
  set_callback :expire_keys, :before, :expire_keys

  attr_accessor :store, :response_stack

  def initialize(store = {})
    @store = store
    @response_stack = []
  end

  def set(k,v)
    run_callbacks :expire_keys do
      @store[k] = { value: v }
      record_response('OK')
    end
  end

  def hmset(k,arr)
    run_callbacks :expire_keys do
      @store[k] = { value: {} } if @store[k].nil?
      hm = @store[k][:value]

      arr.each_slice(2) do |a|
        hm[a[0]] = a[1]
      end
      
      record_response('OK')
    end
  end

  def hget(h,k)
    run_callbacks :expire_keys do
      info = @store[h] || {}
      v = info[:value]
      res = v[k]
      record_response(res)
    end
  end

  def hscan(k, cursor)
    run_callbacks :expire_keys do
      info = @store[k] || {}
      v = info[:value]
      res = []
      v.each do |key, value|
        res << [key, value]
      end
      record_response(["0", res])
    end
  end

  def sadd(k,v)
    run_callbacks :expire_keys do
      @store[k] = { value: Set.new } if @store[k].nil?
      s = @store[k][:value]
      if s.include? v
        response = "0"
      else 
        response = "1"
      end
      s.add(v)
      record_response(response)
    end
  end

  def srem(k,v)
    run_callbacks :expire_keys do
      @store[k] = { value: Set.new } if @store[k].nil?
      s = @store[k][:value]
      if s.include? v
        response = "1"
      else 
        response = "0"
      end
      s.delete(v)
      record_response(response)
    end
  end

  def sismember(k,v)
    run_callbacks :expire_keys do
      s = @store[k] || { :value => Set.new }
      s = s[:value]
      if s.include? v
        response = "1"
      else 
        response = "0"
      end
      record_response(response)
    end
  end

  def del(*k)
    deleted = 0
    k.each do |key|
      deleted += 1 if @store.key?(key)
      @store.delete(key)
    end
    record_response(deleted.to_s)
  end

  def setex(k,s,v)
    set(k,v)
    expire(k,s)
  end

  # NOTE: redis 'get' calls return strings only
  def get(k)
    run_callbacks :expire_keys do
      info = @store[k] || {}
      v = info[:value]
      res = v.to_s if v
      record_response(res)
    end
  end

  def incr(key)
    run_callbacks :expire_keys do
      @store[key] = @store[key] || { value: 0 }
      record_response(@store[key][:value] += 1)
    end
  end

  def expire(key, s)
    run_callbacks :expire_keys do
      res = if @store[key].blank?
              false
            else
              @store[key][:expire] = Time.now + s
              true
            end
      record_response(res)
    end
  end

  # NOTE: per redis-rb spec, this returns a list of replies for all commands
  # run in the block
  def multi(&block)
    empty_responses!
    yield
    @response_stack
  end

  private

  def expire_keys
    @store.select! do |key, info|
      info[:expire].blank? || Time.now < info[:expire]
    end
  end

  # returns the response for convenience
  def record_response(res)
    @response_stack << res
    res
  end

  def empty_responses!
    @response_stack = []
  end
end
