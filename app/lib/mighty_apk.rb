require_relative 'mighty_apk/market_api'
require_relative 'mighty_apk/market'

# production is eager loaded. redefining the protocol buffer file causes errors
unless Rails.application.config.eager_load
  require_relative 'mighty_apk/googleplay.pb'
end

module MightyApk
end
