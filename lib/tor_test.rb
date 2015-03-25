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
        response = http.get(uri.path)
      end
      
      response.body
    end
    
  end
  
end