class SdkCategoryHotStore < HotStore

  def initialize(redis_store: nil)
    super(redis_store: redis_store)

    @key_set = "sdk_category_keys"
  end

  def read(name)
    read_entry("sdk_category", nil, name, override_key: "sdk_category:#{name}")
  end

end
