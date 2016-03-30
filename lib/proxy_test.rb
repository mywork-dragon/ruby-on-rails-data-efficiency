class ProxyTest
  include HTTParty
  include ProxyBase

  base_uri 'https://wtfismyip.com'
  format :json

  def self.check_ip
    http_proxy('52.90.155.249', 8888) if Rails.env.production?
    get('/json')
  end
end

