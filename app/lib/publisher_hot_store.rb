class PublisherHotStore < HotStore

  KEY_TYPE = 'publisher'.freeze

  def initialize(redis_store: nil)
    super(redis_store: redis_store)

    @key_set = "publisher_keys"

    @platform_to_class = {
      "ios" => IosDeveloper,
      "android" => AndroidDeveloper
    }

    @fields_to_normalize = {
      "ios" => {},
      "android" => {}
    }
  end

  def write(platform, publisher_id)
    publisher_class = to_class(platform)
    publisher_attributes = publisher_class.find(publisher_id).hotstore_json
    write_entry(KEY_TYPE, platform, publisher_id, publisher_attributes)
  end

  def read(platform, publisher_id)
    read_entry(KEY_TYPE, platform, publisher_id)
  end

  def delete(platform, publisher_id)
    delete_entry(KEY_TYPE, platform, publisher_id)
  end

end
