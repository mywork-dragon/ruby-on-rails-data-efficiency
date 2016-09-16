class GooglePlayStore
  class Unavailable < RuntimeError; end
  class NotFound < RuntimeError; end
  class UnknownCondition < RuntimeError; end

  include HTTParty
  include ProxyParty

  base_uri 'https://play.google.com/store/apps/details'
  format :html

  def self.lookup(bundle_id, proxy_type: nil)
    res = proxy_request(proxy_type: proxy_type) do
      get('/', query: { 'id' => bundle_id, 'hl' => 'en' }, headers: random_browser_header)
    end
    validate(res)
    res
  end

  def self.validate(http_res)
    return if http_res.code == 200
    raise NotFound if http_res.code == 404
    raise Unavailable if http_res.code == 403
    raise UnknownCondition, "Response code: #{http_res.code}"
  end
end
