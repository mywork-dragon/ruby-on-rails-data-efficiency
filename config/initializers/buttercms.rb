require 'buttercms-ruby'

# If you added the Heroku Butter add-on, ENV["BUTTER_TOKEN"] will be defined.
# Otherwise, grab your token at https://buttercms.com/profile/ and set it below
ButterCMS::api_token = ENV['BUTTER_TOKEN']

# Fallback Data Store in redis
# When a data store is set, on every successful API request the response is written to the data store.
# When a subsequent API request fails, the client attempts to fallback to the value in the data store.
ButterCMS::data_store = :redis, "redis://#{ENV['VARYS_REDIS_URL']}:#{ENV['VARYS_REDIS_PORT']}"
