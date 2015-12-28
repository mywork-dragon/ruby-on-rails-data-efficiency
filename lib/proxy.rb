class Proxy

  class << self

    # Get the response from a get request
    # If get fails, will throw an error
    # @author Stephen Kennedy
    # @author Osman Khwaja
    # @author Jason Lew
    # @return The response (CurbFu::Response::Base)

    # @note Will run from local IP if not in production mode
    def get(req:, params: {}, type: :get, proxy: nil) 

      if Rails.env.production?
        
        mp = proxy || get_proxy_by_type
        
        proxy = "#{mp}:8888"

        return CurbFu.send(type, req, params) do |curb|

          # Defaults
          curb.proxy_url = proxy
          curb.ssl_verify_peer = false
          curb.max_redirects = 3
          curb.follow_location = true
          curb.timeout = 120

          curb.on_complete do |curl_response|
            configure_curb_encoding(curl_response)
          end

          yield(curb) if block_given? # Can override
        end

      else

        return CurbFu.send(type, req, params) do |curb|

          # Defaults
          curb.follow_location = true
          curb.ssl_verify_peer = false
          curb.max_redirects = 3
          curb.timeout = 120

          curb.on_complete do |curl_response|
            configure_curb_encoding(curl_response)
          end

          

          yield(curb) if block_given? # Can override
        end

      end

    end

    def get_proxy_by_type(type: nil)

      if type == :ios_classification
        ios_proxies.sample
      else
        MicroProxy.where(active: true).pluck(:private_ip).sample
      end
    end

    # Gets the body only
    # @author Jason Lew
    # @return The body (String)
    def get_body(req:, params: {}, type: :get, proxy: nil)
      get(req: req, params: params, type: type, proxy: proxy).body
    end

    # Get the body as Nokogiri
    # @author Jason Lew
    # @return A Nokogiri::HTML::Document of the page
    def get_nokogiri(req:, params: {}, type: :get, proxy_type: nil)
      proxy = proxy_type.nil? ? nil : get_proxy_by_type(type: proxy_type)
      Nokogiri::HTML(get_body(req: req, params: params, type: type, proxy: proxy))
    end

    def get_nokogiri_with_wait(req:, params: {}, type: :get)
      body = nil
      5.times do
        begin
          sleep(rand(0.5..1.5))
          body = Nokogiri::HTML(get_body(req: req, params: params, type: type))
        rescue
          nil
        else
          break
        end
      end
      body
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

    def ios_proxies
      %w(
      172.31.27.59
      172.31.17.15
      172.31.27.144
      172.31.30.200
      172.31.22.114
      172.31.16.195
      172.31.23.89
      172.31.23.147
      172.31.19.236
      172.31.29.96
      172.31.28.34
      172.31.23.178
      172.31.21.224
      172.31.17.134
      172.31.23.251
      172.31.21.179
      172.31.22.31
      172.31.29.14
      172.31.31.239
      172.31.20.95
      172.31.28.15
      172.31.30.182
      172.31.22.36
      172.31.30.103
      172.31.27.154
      172.31.17.27
      172.31.31.209
      172.31.31.187
      172.31.19.7
      172.31.18.65
      172.31.28.255
      172.31.19.115
      172.31.30.179
      172.31.21.75
      172.31.17.81
      172.31.19.76
      172.31.23.173
      172.31.27.245
      172.31.29.215
      172.31.30.151
      172.31.16.142
      172.31.24.33
      172.31.25.235
      172.31.24.161
      172.31.24.164
      172.31.22.250
      172.31.27.22
      172.31.22.202
      172.31.30.170
      172.31.24.107
      )
    end

    private 

    # Support UTF-8
    # https://github.com/vcr/vcr/issues/150#issuecomment-4648446
    # @author Jason Lew
    def configure_curb_encoding(curl_response)
      encoding = 'UTF-8'
      encoding = $1 if curl_response.header_str =~ /charset=([-a-z0-9]+)/i
      encoding = $1 if curl_response.body_str =~ %r{<meta[^>]+content=[^>]*charset=([-a-z0-9]+)[^>]*>}mi
      curl_response.body_str.force_encoding(encoding)
    end

  end

end