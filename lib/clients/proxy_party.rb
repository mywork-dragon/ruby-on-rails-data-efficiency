module ProxyParty

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods

    include ProxyBase

    # For one off request
    def get_proxy_options(opts:)
      res = {
        http_proxyaddr: nil,
        http_proxyport: nil
      }

      if Rails.env.production?
        proxy_info = select_proxy(proxy_type: opts[:proxy_type])
        res[:http_proxyaddr], res[:http_proxyport] = proxy_info[:ip], proxy_info[:port]
      end

      res
      
    end

    # For modifying the default options on the client
    def proxy_request(proxy_type: nil)
      if Rails.env.production?
        proxy_info = select_proxy(proxy_type: proxy_type)
        http_proxy(proxy_info[:ip], proxy_info[:port])
      end
      res = yield
      http_proxy(nil, nil) if Rails.env.production?
      res
    end
  end
end

