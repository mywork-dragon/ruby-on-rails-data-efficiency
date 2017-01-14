class FbGraphApi

  include HTTParty
  include ProxyParty

  base_uri 'http://graph.facebook.com'
  format :json

  class FailedRequest < RuntimeError; end

  def self.lookup(fb_id)
    proxy_request(proxy_type: :general) do
      res = get("/#{fb_id}")
      validate!(res)
      JSON.parse(res.body)
    end
  end

  def self.validate!(res)
    raise FailedRequest, res.body unless res.code == 200
  end
end
