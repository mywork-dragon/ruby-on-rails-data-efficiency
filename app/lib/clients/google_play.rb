class GooglePlay

  include HTTParty
  include ProxyParty

  base_uri 'https://play.google.com/store/apps/details'
  format :html

  def self.lookup(bundle_id, proxy_type: nil)
    proxy_request(proxy_type: proxy_type) do
      get('/', query: { 'id' => bundle_id, 'hl' => 'en' }, headers: random_browser_header)
    end
  end
end
