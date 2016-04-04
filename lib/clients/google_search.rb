class GoogleSearch

  include HTTParty
  include ProxyParty

  # :(. Cannot get RVM + Homebrew + OpenSSL working correctly. Should only affect Mac's (dev + dark side machines)
  base_uri ENV['rvm_path'].nil? ? 'https://www.google.com' : 'http://www.google.com'
  format :html

  # http://stackoverflow.com/questions/23995700/what-is-the-porpose-of-the-google-search-parameter-gbv
  def self.query(query, proxy_type: nil)
    proxy_request(proxy_type: proxy_type) do
      get('/search', query: {'q' => query, 'gbv' => '1'}, headers: random_browser_header)
    end
  end
end
