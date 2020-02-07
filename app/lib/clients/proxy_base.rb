module ProxyBase

  def select_proxy(proxy_type: nil, region: nil)
    if proxy_type == :android_classification
      android_proxies(region)
    # elsif proxy_type == :appmonsta
      # return appmonsta_api_url
    else
      general_proxies
    end
  end

  private

  def general_proxies
    { ip: ENV['MICRO_PROXY_URL'], port: ENV['MICRO_PROXY_PORT'] }
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
