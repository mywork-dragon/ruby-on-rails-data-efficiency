# ApkDownloader.module_eval do

# 	# class << self
# 		# def download! package, destination
# 	class Api
# 		private
# 	    def recursive_apk_fetch url, cookie, tries = 5

# 	    	puts "asdfasdfadf"

# 	      # raise ArgumentError, 'HTTP redirect too deep' if tries == 0

# 	      # http = Net::HTTP.new url.host, url.port
# 	      # http.verify_mode = OpenSSL::SSL::VERIFY_NONE

# 	      # req = Net::HTTP::Get.new url.to_s
# 	      # req['Accept-Encoding'] = ''
# 	      # req['User-Agent'] = 'AndroidDownloadManager/4.1.1 (Linux; U; Android 4.1.1; Nexus S Build/JRO03E)'
# 	      # req['Cookie'] = [cookie.name, cookie.value].join('=')

# 	      # resp = http.request req
# 	      # resp.use_ssl = true	# patch

# 	      # case resp
# 	      # when Net::HTTPSuccess
# 	      #   return resp
# 	      # when Net::HTTPRedirection
# 	      #   return recursive_apk_fetch(URI(resp['Location']), cookie, tries - 1)
# 	      # else
# 	      #   resp.error!
# 	      # end
# 	    end
# 	end
# 		# end
# 	# end

# end
