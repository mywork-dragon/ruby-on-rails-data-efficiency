module ProxyBase

  def select_proxy(proxy_type: nil, region: nil)
    if proxy_type == :android_classification
      android_proxies(region)
    else
      { ip: ENV['MICRO_PROXY_URL'], port: ENV['MICRO_PROXY_PORT'] }
    end
  end

  def android_proxies(region)
    if region == nil
      return general_proxies
    end
    # Try a random regional proxy.
    proxy = MicroProxy.where(
      region: MicroProxy.regions[region],
      purpose: MicroProxy.purposes[:region],
      active:true).sample
    { ip: proxy.private_ip, port: 8888, user: ENV['REGIONAL_PROXY_USER'], password: ENV['REGIONAL_PROXY_PASSWORD'] }
  end

end
