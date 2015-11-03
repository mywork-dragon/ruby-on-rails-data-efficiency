class Proxy

	class << self

		def get(req:, params: {}, type: :get)

			if Rails.env.production?

		      begin

		        mp = MicroProxy.transaction do

		          p = MicroProxy.lock.where(active: true).order(last_used: :asc).first
		          p.last_used = DateTime.now
		          p.save

		          p

		        end

		        proxy = "#{mp.private_ip}:8888"

		        response = CurbFu.send(type, req, params) do |curb|
		          curb.proxy_url = proxy
		          curb.ssl_verify_peer = false
		          curb.max_redirects = 3
		          curb.timeout = 120
		          yield(curb) if block_given?
		        end

		      rescue

		        nil

		      end

		    else

	          begin
	            response = CurbFu.send(type, req, params) do |curb|
	            	curb.ssl_verify_peer = false
	            	curb.max_redirects = 3
	            	curb.timeout = 120
	            	yield(curb) if block_given?
	  		      end

	          rescue => e

	            e.message

	          end

		    end

		end

	    # Wrapper that allows you to just pass in a URL
	    # @author Jason Lew
	    # @note Also randomizes the User Agent
	    def get_url(url, params: {})
	      uri = URI(url)
	      get(req: {host: uri.host + uri.path, protocol: uri.scheme, headers: {'User-Agent' => UserAgent.random_web}}, params: params)
	    end

	end

end