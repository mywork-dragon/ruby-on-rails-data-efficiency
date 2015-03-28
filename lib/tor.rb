require 'socksify/http'

class Tor

  class << self
    
    def get(url)
      
      if !Rails.env.production?
        return open(url, UserAgent.random_web)
      end
      
      proxy = next_proxy
      proxy.last_used = DateTime.now
      proxy.save
      
      page = get_using_proxy(url, proxy.private_ip)
      
      page
    end
    
    def test(urls=['https://itunes.apple.com/us/app/dropbox/id327630330?mt=8','https://itunes.apple.com/us/app/tinder/id547702041?mt=8', 'https://itunes.apple.com/us/app/league-date-intelligently/id893653132?mt=8', 'https://play.google.com/store/apps/details?id=com.ubercab&hl=en', 'https://play.google.com/store/apps/details?id=com.supercell.clashofclans&hl=en'])
      o = []
      
      urls.each do |url|
        o << Tor.get(url)
      end
      
      o
    end
    
    private
    
    def next_proxy
      Proxy.order(last_used: :asc).limit(5).sample
    end
    
    def get_using_proxy(url, ip, limit=10)
      raise ArgumentError, 'HTTP redirect too deep' if limit == 0
      
      uri = URI.parse(url)
      
      sp = Net::HTTP.SOCKSProxy(ip, 9050).new(uri.host, uri.port)
      sp.use_ssl = true if uri.scheme == 'https'
      
      req = Net::HTTP::Get.new(uri)

      req['User-Agent'] = UserAgent.random_web
      req['Accept'] = URI.encode('text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8')
      
      response = sp.start {|http|
        http.request(req)
      }
      
      case response
      when Net::HTTPSuccess      
        response.body
      when Net::HTTPRedirection  
        location = response['location']
        #puts "Redirected to: #{location}"
        get_using_proxy(location, ip, limit - 1)
      else
        response.error!
      end
      
    end
    
  end

end