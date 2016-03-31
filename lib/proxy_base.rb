module ProxyBase
  
  def select_proxy(proxy_type: nil)
    proxies = if proxy_type == :ios_classification
      ios_proxies
    elsif proxy_type == :android_classification
      android_proxies
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

  def android_proxies
    ios_proxies
  end

end
