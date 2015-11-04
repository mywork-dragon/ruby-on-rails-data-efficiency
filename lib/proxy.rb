class Proxy

	class << self

    # Get the response from a get request
    # If get fails, will throw an error
    # @author Stephen Kennedy
    # @author Osman Khwaja
    # @author Jason Lew
    # @return The response (CurbFu::Response::Base)
    # @note Will run from local IP if not in production mode
    def get(req:, params: {}, type: :get) 
			if Rails.env.production?

        mp = MicroProxy.transaction do
          p = MicroProxy.lock.where(active: true).order(last_used: :asc).first
          p.last_used = DateTime.now
          p.save
          p
        end

        proxy = "#{mp.private_ip}:8888"

        return CurbFu.send(type, req, params) do |curb|

          # Defaults
          curb.proxy_url = proxy
          curb.ssl_verify_peer = false
          curb.max_redirects = 3
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

    # Get the body, passing in only the URL
    # @author Jason Lew
    # @url The URL to get
    # @param The HTTP params
    # @return The body (String)
    # @note Also randomizes the User Agent
    def get_body_from_url(url, params: {})
      uri = URI(url)
      get_body(req: {host: uri.host + uri.path, protocol: uri.scheme, headers: {'User-Agent' => UserAgent.random_web}}, params: params)
    end

	end

end