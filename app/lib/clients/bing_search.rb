class BingSearch

  include HTTParty
  include ProxyParty

  base_uri 'https://www.bing.com'
  format :html

  def self.query(query, proxy_type: nil)
    proxy_request(proxy_type: proxy_type) do
      get('/search', query: {'q' => query }, headers: random_browser_header)
    end
  end
end
