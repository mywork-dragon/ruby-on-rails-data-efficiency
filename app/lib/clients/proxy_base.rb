module ProxyBase
  
  def select_proxy(proxy_type: nil)
    proxies = if proxy_type == :ios_classification
      ios_proxies
    elsif proxy_type == :android_classification
      android_proxies
    elsif proxy_type == :all_static
      all_static_proxies
    elsif proxy_type == :temporary_proxies
      temporary_proxy_load_balancers
    else
      general_proxies
    end

    {
        ip: proxies.sample,
        port: 8888
    }
  end

  def general_proxies
    MicroProxy.where(purpose: MicroProxy.purposes[:general], active:true).pluck(:private_ip)
  end

  def ios_proxies
    MicroProxy.where(purpose: MicroProxy.purposes[:ios], active:true).pluck(:private_ip)
  end

  def all_static_proxies
    MicroProxy.where(active: true).pluck(:private_ip)
  end

  def android_proxies
    ios_proxies
  end

  # load balancers that will forward address to temporary proxies
  # TODO: hard-coded for now...move to DB
  def temporary_proxy_load_balancers
    [
      'internal-01-proxy-balancer-633334655.us-east-1.elb.amazonaws.com',
      'internal-02-proxy-balancer-1130238239.us-east-1.elb.amazonaws.com'
    ]
  end

end
