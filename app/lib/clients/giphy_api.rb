class GiphyApi
  include HTTParty
  include ProxyParty

  base_uri 'https://giphy.com'
  format :html

  def self.search_html(term)
    search_term_cleaned = CGI::escape(term)
    proxy_request(proxy_type: :general) do
      get("/search/#{search_term_cleaned}")
    end
  end

end
