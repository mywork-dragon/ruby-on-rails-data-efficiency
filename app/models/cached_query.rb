class CachedQuery
  def initialize(sql, connection, params: [], expires: 12.hours, key: nil, force: false, compress: true, cache_prefix: "varys-query-cache")
    @expires = expires
    @sql = sql
    @key = key || generate_key(sql)
    @force = force
    @compress = true
    @connection = connection
    @cache_prefix = cache_prefix
    @params = params
  end

  def generate_key(sql)
    digest = Digest::SHA1.hexdigest(sql + @params.to_json)
    "#{@cache_prefix}:#{digest}"
  end

  def fetch
    if @force
      _get_response
    else
      Rails.cache.fetch(@key, expires_in: @expires, compress: @compress) do
        _get_response
      end
    end
  end

  def _get_response
    res = @connection.get_connection {|conn| conn.exec_params(@sql, @params) }
    res.to_a
  end
end
