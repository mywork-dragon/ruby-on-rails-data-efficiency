require 'socksify/http'
class TorTest
  
  class << self
    
    def run
      uri = URI.parse('http://wtfismyip.com/json/')
      response = nil
      Net::HTTP.SOCKSProxy('127.0.0.1', 9050).start(uri.host, uri.port) do |http|
        response = http.get(uri.path)
      end
      
      response.body
    end
    
    def run_remote(ip)
      uri = URI.parse('http://wtfismyip.com/json/')
      response = nil
      Net::HTTP.SOCKSProxy(ip, 9050).start(uri.host, uri.port) do |http|
        response = http.get(uri.path)
      end
      
      response.body
    end
    
    def get(url, ip='172.31.41.122')
      uri = URI.parse(url)
      response = nil
      Net::HTTP.SOCKSProxy(ip, 9050).start(uri.host, uri.port) do |http|
        http.use_ssl = true if uri.scheme == 'https'
        
        response = http.get(uri.path)
      end
      
      response.body
    end
    
    def get2(url, ip='172.31.41.122', limit=10)
      raise ArgumentError, 'HTTP redirect too deep' if limit == 0
      
      uri = URI.parse(url)
      
      socks_proxy = Net::HTTP.SOCKSProxy(ip, 9050)
      socks_proxy.use_ssl = true if uri.scheme == 'https'
      
      response = socks_proxy.start(uri.host, uri.port) do |http|
        req = http.get(uri.path, 'User-Agent' => UserAgent.random_web)
      end
      
      case response
      when Net::HTTPSuccess     then response.body
      when Net::HTTPRedirection then get2(response['location'], limit - 1)
      else
        response.error!
      end
      
    end
    
    # def fetch(uri_str, limit = 10)
    #   # You should choose better exception.
    #   raise ArgumentError, 'HTTP redirect too deep' if limit == 0
    #
    #   url = URI.parse(uri_str)
    #   req = Net::HTTP::Get.new(url.path, { 'User-Agent' => ua })
    #   response = Net::HTTP.start(url.host, url.port) { |http| http.request(req) }
    #   case response
    #   when Net::HTTPSuccess     then response
    #   when Net::HTTPRedirection then fetch(response['location'], limit - 1)
    #   else
    #     response.error!
    #   end
    # end
    #
    
  end
  
end