class GoogleSearch

  include HTTParty
  include ProxyParty

  base_uri 'https://www.google.com'
  format :html

  # http://stackoverflow.com/questions/23995700/what-is-the-porpose-of-the-google-search-parameter-gbv
  def self.query(query, proxy_type: nil)
    proxy_request(proxy_type: proxy_type) do
      get('/search', query: {'q' => query, 'gbv' => '1'}, headers: random_browser_header)
    end
  end
end
