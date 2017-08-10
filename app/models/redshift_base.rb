class RedshiftBase < ActiveRecord::Base
  self.abstract_class = true
  establish_connection Rails.application.config.redshift_db_config[Rails.env.to_s]

  class CachedQuery
    def initialize(sql, expires: 12.hours, key: nil, force: false, compress: true)
      @expires = expires
      @sql = sql
      @key = key || generate_key(sql)
      @force = force
      @compress = true
    end

    def generate_key(sql)
      digest = Digest::SHA1.hexdigest(sql)
      "varys-redshift-cache:#{digest}"
    end

    def fetch
      if @force
        _get_response
      else
        Rails.cache.fetch(@key, expires: @expires, compress: @compress) do
          _get_response
        end
      end
    end

    def _get_response
      res = RedshiftBase.connection.execute(@sql)
      res.to_a
    end
  end

  class << self
    def cached_request(key:, expires: 12.hours, compress: true)
      cache_key = "varys-redshift-cache:#{key}"
      Rails.cache.fetch(cache_key, expires_in: expires, compress: compress) do
        yield
      end
    end

    def query(sql, options={})
      CachedQuery.new(sql, options)
    end
  end
end
