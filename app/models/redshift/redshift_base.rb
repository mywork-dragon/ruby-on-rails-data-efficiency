class RedshiftBase < ActiveRecord::Base
  self.abstract_class = true
  establish_connection Rails.application.config.redshift_db_config[Rails.env.to_s]

  class << self
    def cached_request(key:, expires: 12.hours, compress: true)
      cache_key = "varys-redshift-cache:#{key}"
      Rails.cache.fetch(cache_key, expires_in: expires, compress: compress) do
        yield
      end
    end
  end
end
