module ProxyParty

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods

    include ProxyBase

    def proxy_request(proxy_type: nil)
      proxy_info = select_proxy(proxy_type: proxy_type)
      http_proxy(proxy_info[:ip], proxy_info[:port]) if Rails.env.production?
      res = yield
      http_proxy(nil, nil) if Rails.env.production?
      res
    end
  end
end

