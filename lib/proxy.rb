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
		        end

		      rescue

		        nil

		      end

		    else

          begin
  		      
            response = CurbFu.send(type, req, params) do |curb|
            	curb.follow_location = true
  		        curb.ssl_verify_peer = false
  		        curb.max_redirects = 3
  		        curb.timeout = 120
  		      end

          rescue => e

            e.message

          end

		    end

		end

	end

end