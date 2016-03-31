class ProxyRequest

  include HTTParty
  include ProxyParty

  # TODO: not working. Returning the body. Not blocking though
  def self.head(url, opts: {})
    proxy_opts = get_proxy_options(opts: opts)
    HTTParty.head(url, proxy_opts.merge(opts))
  end

  def self.get(url, opts: {})
    proxy_opts = get_proxy_options(opts: opts)
    HTTParty.get(url, proxy_opts.merge(opts))
  end

end
