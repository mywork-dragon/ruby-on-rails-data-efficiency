class PublisherHotStore < HotStore

  def initialize()
    super

    @key_set = "publisher_keys"

    @platform_to_class = {
      "ios" => IosDeveloper,
      "android" => AndroidDeveloper
    }

    @fields_to_normalize = {
      "ios" => {
        :app_store_id => "publisher_identifier"
      },
      "android" => {
        :identifier => "publisher_identifier",
      }
    }
  end

  def write(platform, publisher_id)
    publisher_class = to_class(platform)
    publisher_attributes = publisher_class.find(publisher_id).api_json
    write_entry("publisher", platform, publisher_id, publisher_attributes)
  end

  def read(platform, publisher_id)
    read_entry("publisher", platform, publisher_id)
  end

  def delete(platform, publisher_id)
    delete_entry("publisher", platform, publisher_id)
  end

end