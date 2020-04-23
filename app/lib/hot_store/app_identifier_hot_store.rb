class AppIdentifierHotStore < HotStore

  # We don't have a key_set in the hotstore for this mapping

  KEY_TYPE = 'ai'.freeze

  def write(platform, app_identifier, id)
    write_flat_entry(KEY_TYPE, platform, app_identifier, id)
  end
end
