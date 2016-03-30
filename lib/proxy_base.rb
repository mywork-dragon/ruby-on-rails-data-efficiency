module ProxyBase
  
  def select_proxy(type: nil)
    proxies = if type == :ios_classification
      ios_proxies
    elsif type == :android_classification
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
