class HotStore

  @@STARTUP_NODES = [
    {:host => ENV['HOT_STORE_REDIS_URL'], :port => ENV['HOT_STORE_REDIS_PORT'] }
  ]

  @@MAX_CONNECTIONS = (ENV['HOT_STORE_REDIS_MAX_CONNECTIONS'] || 1).to_i

  def initialize()
    @redis_store = RedisCluster.new(@@STARTUP_NODES, @@MAX_CONNECTIONS)
  end

private

  def to_class(platform)
    return @platform_to_class[platform]
  end

  def key(type, platform, application_id)
    "#{type}:#{platform}:#{application_id}"
  end

  def write_entry(type, platform, id, attributes, override_key: nil)
    entry_key = override_key || key(type, platform, id)

    if @fields_to_normalize
      normalized_fields = @fields_to_normalize[platform]
      normalized_fields.each do |from, to|
        if not attributes.key?(to)
          attributes[to] = attributes[from]
          attributes.delete(from)
        end
      end
    end

    attributes_array = []
    compressed_attributes = {} # Save the compressed attributes seperately since hmset doesn't handle compressed encodings.

    attributes.each do |key, value|
      if @compressed_fields.include? key.to_s
        compressed_attributes[key] = ActiveSupport::Gzip.compress(value.to_json)
      else
        if value
          attributes_array << key.to_s
          attributes_array << value.to_json
        end
      end
    end
    
    @redis_store.hmset(entry_key, attributes_array) if attributes_array.any?

    compressed_attributes.each do |key, value|
      @redis_store.hset(entry_key, key, value)
    end

    @redis_store.sadd(@key_set, entry_key)
  end

  def read_entry(type, platform, id, override_key: nil)
    entry_key = override_key || key(type, platform, id)

    attributes = {}
    
    cursor = read_scanned_attributes(type, entry_key, "0", attributes)
    while cursor != "0"
      cursor = read_scanned_attributes(type, entry_key, cursor, attributes)
    end

    attributes
  end

  def delete_entry(type, platform, id, override_key: nil)
    entry_key = override_key || key(type, platform, id)
    @redis_store.srem(@key_set, entry_key)
    @redis_store.del(entry_key)
  end

  def read_scanned_attributes(type, entry_key, entry_cursor, entry_attributes)
    cursor, attributes = @redis_store.hscan(entry_key, entry_cursor)
    attributes.each do |attribute_tuple|
      if @compressed_fields.include? attribute_tuple[0]
        entry_attributes[attribute_tuple[0]] = ActiveSupport::Gzip.decompress(attribute_tuple[1])
      else
        entry_attributes[attribute_tuple[0]] = attribute_tuple[1]
      end
    end
    cursor
  end

end