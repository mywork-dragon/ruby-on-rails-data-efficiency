module ProxyParty
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def proxy_request
      http_proxy('172.31.26.224', '8888') if Rails.env.production?
      res = yield
      http_proxy(nil, nil) if Rails.env.production?
      res
    end
  end
end

