class HotStore
  # All operations in this class should use the with_connection method to obtain a connection to the
  # redis server. That method properly either returns the injected mock connection for test, or a connection
  # that is checked out from the HotStore threadpool.

  class MissingHotStoreField < RuntimeError; end
  class MalformedHotStoreField < RuntimeError; end

  require_relative 'hot_store_thread_pool'

  @@STARTUP_NODES = [
    {:host => ENV['HOT_STORE_REDIS_URL'], :port => ENV['HOT_STORE_REDIS_PORT'] }
  ]

  @@MAX_CONNECTIONS = (ENV['HOT_STORE_REDIS_MAX_CONNECTIONS'] || 1).to_i

  def initialize(redis_store: nil)
    @redis_store = redis_store if redis_store
  end

  EXPIRATION_TIME_IN_SECS = Time.now.minus_with_coercion(2.months.ago).to_i
  TIME_OF_RELEVANCE = 2.years.ago

private

  def to_class(platform)
    return @platform_to_class[platform]
  end

  def key(type, platform, key_id)
    "#{type}:#{platform}:#{key_id}"
  end

  def write_flat_entry(type, platform, key_id, key_val)
    entry_key = key(type, platform, key_id)

    with_connection do |connection|
      if connection.set(entry_key, key_val)
        connection.expire(entry_key, EXPIRATION_TIME_IN_SECS)
        true
      end
    end
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

    unless all_required_fields_exist?(attributes)
      raise MissingHotStoreField.new("Type: #{type} Platform: #{platform} Id: #{id}")
    end

    # Send separate requests for compressed and uncompressed fields since the write will fail
    # with an encoding error if
    attributes_array = []
    compressed_attributes_array = []

    attributes.each do |key, value|
      if value != nil
        raw_value = value.to_json
        gzipped_value = ActiveSupport::Gzip.compress(raw_value)
        if gzipped_value.bytesize < raw_value.bytesize
          compressed_attributes_array << key.to_s
          compressed_attributes_array << gzipped_value
        else
          attributes_array << key.to_s
          attributes_array << raw_value
        end
      end
    end

    return if attributes_array.empty? and compressed_attributes_array.empty?

    with_connection do |connection|
      if attributes_array.any?
        # Can't use multi in cluster setup
        if connection.hmset(entry_key, attributes_array)
          connection.expire(entry_key, EXPIRATION_TIME_IN_SECS)
          connection.sadd(@key_set, entry_key)
        end
      end

      if compressed_attributes_array.any?
        # Can't use multi in cluster setup
        if connection.hmset(entry_key, compressed_attributes_array)
          connection.expire(entry_key, EXPIRATION_TIME_IN_SECS)
          connection.sadd(@key_set, entry_key)
        end
      end
    end
  end

  def read_entry(type, platform, id, override_key: nil)
    entry_key = override_key || key(type, platform, id)

    attributes = {}

    with_connection do |connection|
      cursor = read_scanned_attributes(type, entry_key, "0", attributes, connection)
      while cursor != "0"
        cursor = read_scanned_attributes(type, entry_key, cursor, attributes, connection)
      end
    end

    attributes
  end

  def delete_entry(type, platform, id, override_key: nil)
    entry_key = override_key || key(type, platform, id)

    with_connection do |connection|
      connection.srem(@key_set, entry_key)
      connection.del(entry_key)
    end

  end

  def read_scanned_attributes(type, entry_key, entry_cursor, entry_attributes, connection)
    cursor, attributes = connection.hscan(entry_key, entry_cursor)
    attributes.each do |attribute_tuple|
      begin
        is_gzipped = false
        begin
          begin
            is_gzipped = attribute_tuple[1].start_with?("\x1F\x8B")
          rescue Encoding::CompatibilityError => e
            is_gzipped = attribute_tuple[1].start_with?("\x1F\x8B".force_encoding("UTF-8"))
          end
        rescue Encoding::CompatibilityError => e
          is_gzipped = attribute_tuple[1].start_with?("\x1F\x8B".force_encoding("ASCII-8BIT"))
        end

        if is_gzipped
          entry_attributes[attribute_tuple[0]] = ActiveSupport::JSON.decode(ActiveSupport::Gzip.decompress(attribute_tuple[1]))
        else
          entry_attributes[attribute_tuple[0]] = ActiveSupport::JSON.decode(attribute_tuple[1])
        end
      rescue JSON::ParserError, Zlib::GzipFile::Error => e
        Bugsnag.notify(MalformedHotStoreField.new("Key: #{entry_key} Attribute: #{attribute_tuple[0]}"))
      end
    end
    cursor
  end

  def all_required_fields_exist?(app_attributes)
    if @required_fields
      @required_fields.each do |field|
        return false if app_attributes[field].nil?
      end
    end
    true
  end

  def with_connection
    if @redis_store
      yield @redis_store
    else
      HotStoreThreadPool.connection_pool.with do |connection|
        yield connection
      end
    end
  end

end
