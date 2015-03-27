require 'socksify/http'

class Tor

  class << self
    
    def open(url)
      
      proxy = next_proxy
      proxy.last_used = DateTime.now
      proxy.save
      
      page = open_using_proxy(url, proxy.private_ip)
      
      page
    end
    
    def test(urls=['https://itunes.apple.com/us/app/dropbox/id327630330?mt=8','https://itunes.apple.com/us/app/tinder/id547702041?mt=8', 'https://itunes.apple.com/us/app/league-date-intelligently/id893653132?mt=8', 'https://play.google.com/store/apps/details?id=com.ubercab&hl=en', 'https://play.google.com/store/apps/details?id=com.supercell.clashofclans&hl=en'])
      o = []
      
      urls.each do |url|
        o << Tor.open(url)
      end
      
      o
    end
    
    private
    
    def next_proxy
      Proxy.order(last_used: :asc).limit(1).first
    end
    
    def open_using_proxy(url, ip, limit=10)
      raise ArgumentError, 'HTTP redirect too deep' if limit == 0
      
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
        open_using_proxy(location, ip, limit - 1)
      else
        #puts "response: #{response}"
        response.error!
      end
      
    end
    
  end

end