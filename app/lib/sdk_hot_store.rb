class SdkHotStore < HotStore

  @@SDK_FIELDS_TO_DELETE = [ :type ]

  @@SDK_FIELDS_TO_RENAME = {
    :tags => :categories
  }

  def initialize(redis_store: nil)
    super(redis_store: redis_store)

    @key_set = "sdk_keys"
    @platform_to_class = {
      "ios" => IosSdk,
      "android" => AndroidSdk
    }
  end

  def write(platform, sdk_id)
    sdk_class = to_class(platform)
    sdk_attributes = sdk_class.find(sdk_id).as_json

    @@SDK_FIELDS_TO_DELETE.each do |field|
      sdk_attributes.delete(field)
    end

    @@SDK_FIELDS_TO_RENAME.each do |from, to|
      sdk_attributes[to] = sdk_attributes[from]
      sdk_attributes.delete(from)
    end

    write_entry("sdk", platform, sdk_id, sdk_attributes)
  end

  def read(platform, sdk_id)
    read_entry("sdk", platform, sdk_id)
  end

  def delete(platform, sdk_id)
    delete_entry("sdk", platform, sdk_id)
  end

end