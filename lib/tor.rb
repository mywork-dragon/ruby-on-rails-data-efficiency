# require 'socksify/http'

class Tor

  class << self
    
    # @param bypass using the local IP instead (only available in dev)
    def get(url, bypass: false)
      
      if !Rails.env.production? 
        
        if bypass
          return open(url).read
        else
          return get_using_proxy(url, ip: '127.0.0.1') #make sure you run Tor locally
        end
        
      end
    
      if bypass
        raise 'Tor must be used in production'
      end
      
      proxy = next_proxy
      proxy.last_used = DateTime.now
      proxy.save
      
      page = get_using_proxy(url, ip: proxy.private_ip, port: proxy.port)
      
      page
    end
    
    # Checks all proxy servers to see if it can load a page
    def check_servers(url='http://wtfismyip.com/json/')
      es = []
      
      Proxy.all.each do |proxy|
        single_server_result = check_server(url, proxy)
        es << single_server_result unless single_server_result.nil?
      end
      
      puts 'All proxies are fine!' if es.empty?
      
      es
    end
    
    def check_server(url, proxy)
      begin
        page = get_using_proxy(url, ip: proxy.private_ip, port: proxy.port) 
      
        puts ["Proxy id: #{proxy.id}", "Proxy public IP: #{proxy.public_ip}; Response: #{page}"].join(" | ")
        puts ""
      rescue => e
        return {proxy: proxy, message: e.message, backtrace: e.backtrace}
      end
      
      nil
    end
    
    def test(urls=['https://itunes.apple.com/us/app/dropbox/id327630330?mt=8','https://itunes.apple.com/us/app/tinder/id547702041?mt=8', 'https://itunes.apple.com/us/app/league-date-intelligently/id893653132?mt=8', 'https://play.google.com/store/apps/details?id=com.ubercab&hl=en', 'https://play.google.com/store/apps/details?id=com.supercell.clashofclans&hl=en'])
      o = []
      
      urls.each do |url|
        o << Tor.get(url)
      end
      
      o
    end
    
    def next_proxy
      SuperProxy.order(last_used: :asc).limit(5).sample
    end
    
    # Uses old proxy table
    # For Stephen while we get new stuff set up
    def next_proxy_old
      Proxy.order(last_used: :asc).limit(5).sample
    end
    
    def get_using_proxy(url, ip:, port: 9050, limit: 10)
      raise ArgumentError, 'HTTP redirect too deep' if limit == 0
      
      uri = URI.parse(url)
      
      sp = Net::HTTP.SOCKSProxy(ip, port).new(uri.host, uri.port)
      sp.use_ssl = true if uri.scheme == 'https'
      
      req = Net::HTTP::Get.new(uri)

      req['User-Agent'] = UserAgent.random_web
      req['Accept'] = URI.encode('text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8')
      
      response = sp.start { |http| http.request(req) }
      
      case response
      when Net::HTTPSuccess      
        response.body
      when Net::HTTPRedirection  
        location = response['location']
        #puts "Redirected to: #{location}"
        get_using_proxy(location, ip: ip, port: port, limit: limit - 1)
      else
        response.error!
      end
      
    end
    
  end

end