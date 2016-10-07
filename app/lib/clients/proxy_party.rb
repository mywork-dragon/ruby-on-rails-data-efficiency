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

      if opts[:random_user_agent]
        res[:headers] = opts[:headers] || {}
        res[:headers].merge!(random_browser_header)
      end

      res
      
    end

    # For modifying the default options on the client
    def proxy_request(proxy_type: nil)
      set_proxy(proxy_type: proxy_type) if Rails.env.production?
      yield
    ensure
      release_proxy if Rails.env.production?
    end

    def set_proxy(proxy_type: :general)
      proxy_info = select_proxy(proxy_type: proxy_type)
      http_proxy(proxy_info[:ip], proxy_info[:port])
    end

    def release_proxy
      http_proxy(nil, nil)
    end

    def random_browser_header
      {'User-Agent' => UserAgent.random_web}
    end

  end
end

