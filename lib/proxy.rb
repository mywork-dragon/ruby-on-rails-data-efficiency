class Proxy

  class << self

    # Get the response from a get request
    # If get fails, will throw an error
    # @author Stephen Kennedy
    # @author Osman Khwaja
    # @author Jason Lew
    # @return The response (CurbFu::Response::Base)

    # @note Will run from local IP if not in production mode
    def get(req:, params: {}, type: :get, hard_proxy: false) 
      if Rails.env.production?
        
        # use randomization instead of locking
        mp = MicroProxy.select(:id, :private_ip).where(active: true).sample
        mp.last_used = DateTime.now
        begin
          mp.save
        rescue
          nil
        end

        
        proxy = "#{mp.private_ip}:8888"

        return CurbFu.send(type, req, params) do |curb|

          # Defaults
          curb.proxy_url = proxy
          curb.ssl_verify_peer = false
          curb.max_redirects = 3
          curb.follow_location = true
          curb.timeout = 120

          yield(curb) if block_given? # Can override
        end

      else

        return CurbFu.send(type, req, params) do |curb|

          # Defaults
          curb.follow_location = true
          curb.ssl_verify_peer = false
          curb.max_redirects = 3
          curb.timeout = 120

          yield(curb) if block_given? # Can override
        end

      end

    end

    # Gets the body only
    # @author Jason Lew
    # @return The body (String)
    def get_body(req:, params: {}, type: :get)
      get(req: req, params: params, type: type).body
    end

    # Get the body as Nokogiri
    # @author Jason Lew
    # @return A Nokogiri::HTML::Document of the page
    def get_nokogiri(req:, params: {}, type: :get)
      Nokogiri::HTML(get_body(req: req, params: params, type: type)) 
    end

    # Convenience method to get the Response object from just a url
    # @author Osman Khwaja
    # @return The response (CurbFu::Response::Base)
    def get_from_url(url, params: {}, headers: {})
      uri = URI(url)
      get(req: {host: uri.host + uri.path, protocol: uri.scheme, headers: {'User-Agent' => UserAgent.random_web}.merge(headers)}, params: params_from_query(uri.query).merge(params))
    end

    # from a query string, build the params object
    # "id=368677368&uslimit=1" --> {"id"=>"368677368", "uslimit"=>"1"}
    def params_from_query(query)

      return {} if query.nil?

      query.split("&").reduce({}) do |memo, pair|
        parts = pair.split("=")
        if parts.length > 1
          memo[parts.first] = parts.second
          memo
        else
          memo
        end
      end
    end

    # Get the body, passing in only the URL
    # @author Jason Lew
    # @url The URL to get
    # @param The HTTP params
    # @return The body (String)
    # @note Also randomizes the User Agent
    def get_body_from_url(url, params: {}, headers: {})
      uri = URI(url)
      get_body(req: {host: uri.host + uri.path, protocol: uri.scheme, headers: {'User-Agent' => UserAgent.random_web}.merge(headers)}, params: params_from_query(uri.query).merge(params))
    end

    # workaround locking issues
    def get_hard_proxy
      %w(
        172.31.20.1
        172.31.29.18
        172.31.20.230
        172.31.24.153
        172.31.24.26
        172.31.37.27
        172.31.36.192
        172.31.36.118
        172.31.32.44
        172.31.36.248
        172.31.28.223
        172.31.17.197
        172.31.17.16
        172.31.18.173
        172.31.27.168
        172.31.22.203
        172.31.30.9
        172.31.30.83
        172.31.20.155
        172.31.19.221
        172.31.19.59
        172.31.24.40
        172.31.29.43
        172.31.22.60
        172.31.30.139
        172.31.27.164
        172.31.20.8
        172.31.17.76
        172.31.26.149
        172.31.24.147
        172.31.19.147
        172.31.18.158
        172.31.22.222
        172.31.19.185
        172.31.23.246
        172.31.16.176
        172.31.29.67
        172.31.22.106
        172.31.29.31
        172.31.19.52
        172.31.27.53
        172.31.25.190
        172.31.23.204
        172.31.28.30
        172.31.23.81
        172.31.18.237
        172.31.21.142
        172.31.27.169
        172.31.28.197
        172.31.23.243
        ).sample
    end

  end

end