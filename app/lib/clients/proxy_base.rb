module ProxyBase

  def select_proxy(proxy_type: nil, region: nil)
    if proxy_type == :ios_classification
      ios_proxies
    elsif proxy_type == :android_classification
      android_proxies(region)
    elsif proxy_type == :all_static
      all_static_proxies
    elsif proxy_type == :temporary_proxies
      temporary_proxy_load_balancers
    else
      general_proxies
    end
  end

  def general_proxies
    proxies = MicroProxy.where(purpose: MicroProxy.purposes[:general], active:true).pluck(:private_ip)
    { ip: proxies.sample, port: 8888 }
  end

  def ios_proxies
    proxies = MicroProxy.where(purpose: MicroProxy.purposes[:ios], active:true).pluck(:private_ip)
    { ip: proxies.sample, port: 8888 }
  end

  def all_static_proxies
    proxies = MicroProxy.where(active: true).pluck(:private_ip)
    { ip: proxies.sample, port: 8888 }
  end

  def android_proxies(region)
    if region == nil
      return ios_proxies
    end
    # Try a random regional proxy.
    proxy = MicroProxy.where(
      region: MicroProxy.regions[region],
      purpose: MicroProxy.purposes[:region],
      active:true).sample
    { ip: proxy.private_ip, port: 8888, user: ENV['REGIONAL_PROXY_USER'], password: ENV['REGIONAL_PROXY_PASSWORD'] }
  end

  # load balancers that will forward address to temporary proxies
  # TODO: hard-coded for now...move to DB
  def temporary_proxy_load_balancers
    elbs = [
      'internal-01-proxy-balancer-633334655.us-east-1.elb.amazonaws.com',
      'internal-02-proxy-balancer-1130238239.us-east-1.elb.amazonaws.com'
    ]
    { ip: elbs.sample, port: 8888}
  end

end
