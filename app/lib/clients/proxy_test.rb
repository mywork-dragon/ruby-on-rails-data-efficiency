class ProxyTest

  include HTTParty
  include ProxyParty

  base_uri 'https://wtfismyip.com'
  format :json

  def self.check_ip(proxy_type: nil)
    proxy_request(proxy_type: proxy_type) do
      get('/json')
    end
  end

  def self.side_effects
    get('/json')
  end
end

