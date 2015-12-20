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
        
        mp = proxy || get_proxy
        
        proxy = "#{mp}:8888"

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

    def get_proxy
      mp = MicroProxy.select(:id, :private_ip).where(active: true).sample
      mp.last_used = DateTime.now
      begin
        mp.save
      rescue
        nil
      end
      mp.private_ip
    end

    def get_proxy_with_wait
      30.times do
        p = pick_proxy
        return p.private_ip if p.present?
        sleep 1
      end
      get_proxy
    end

    def pick_proxy
      begin
        mp = MicroProxy.where('active = ? AND flags = ? AND last_used < ?',true,0,5.seconds.ago).order(last_used: :asc).limit(3).sample
        if mp.present?
          mp.last_used = DateTime.now
          mp.save
        end
      rescue
        nil
      else
        mp
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
    def get_nokogiri(req:, params: {}, type: :get)
      Nokogiri::HTML(get_body(req: req, params: params, type: type)) 
    end

    def get_nokogiri_with_wait(req:, params: {}, type: :get)
      body = nil
      5.times do
        begin
          timeout(3) do
            body = Nokogiri::HTML(get_body(req: req, params: params, type: type, proxy: get_proxy_with_wait))
          end
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

  end

end