class ProxyRequest

  include HTTParty
  include ProxyParty

  def self.head(url)
    proxy_request {
      get(url)
    }
  end

  def self.get(url)
    HTTParty.get(url)
  end
end
