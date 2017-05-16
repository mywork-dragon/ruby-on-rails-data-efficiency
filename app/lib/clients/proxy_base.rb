module ProxyBase

  def select_proxy(proxy_type: nil, region: nil)
    if proxy_type == :android_classification
      android_proxies(region)
    elsif proxy_type == :all_static
      all_static_proxies
    elsif proxy_type == :temporary_proxies
      { ip: 'micro-proxies.ms-internal.com', port: 8888}
    else
      general_proxies
    end
  end

  def general_proxies
    proxies = MicroProxy.where(purpose: MicroProxy.purposes[:general], active:true).pluck(:private_ip)
    { ip: proxies.sample, port: 8888 }
  end

  def all_static_proxies
    proxies = MicroProxy.where(active: true).pluck(:private_ip)
    { ip: proxies.sample, port: 8888 }
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
