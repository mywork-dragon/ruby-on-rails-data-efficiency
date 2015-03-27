class Tor

  class << self
    
    def open(url)
      
      #get the non-busy server that was used last and is active
      proxy = next_proxy
      proxy.busy = true
      proxy.save
      
      page = open_using_proxy(url, proxy.private_ip)
      
      proxy.last_used = DateTime.now
      proxy.busy = false
      proxy.save
      
      page
    end
    
    def next_proxy
      Proxy.order(last_used: :desc).limit(1).first
    end
    
    def open_using_proxy(url, ip, limit=10)
      raise ArgumentError, 'HTTP redirect too deep' if limit == 0
      
      puts "Using Proxy #{ip}"
      
      uri = URI.parse(url)
      
      sp = Net::HTTP.SOCKSProxy(ip, 9050).new(uri.host, uri.port)
      sp.use_ssl = true if uri.scheme == 'https'
      
      req = Net::HTTP::Get.new(uri)

      req['User-Agent'] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2272.101 Safari/537.36"
      req['Accept'] = "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8"
      
      response = sp.start {|http|
        http.request(req)
      }
      
      case response
      when Net::HTTPSuccess      
        response.body
      when Net::HTTPRedirection  
        location = response['location']
        #puts "Redirected to: #{location}"
        get2(location, ip, limit - 1)
      else
        #puts "response: #{response}"
        response.error!
      end
      
    end
    
    
  end

end