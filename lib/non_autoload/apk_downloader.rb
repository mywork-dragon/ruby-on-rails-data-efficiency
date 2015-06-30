ApkDownloader::Api.module_eval do

  def fetch_apk_data package

    if Rails.env.production?
      proxy = Tor.next_proxy
      proxy.last_used = DateTime.now
      ip = proxy.private_ip
      proxy.save
    elsif Rails.env.development?
      ip = '127.0.0.1'
    end

    TCPSocket::socks_server = ip
    TCPSocket::socks_port = 9050

    log_in!
    doc = details(package).detailsResponse.docV2
    version_code = doc.details.appDetails.versionCode
    offer_type = doc.offer[0].offerType

    message = api_request :post, '/purchase', :ot => offer_type, :doc => package, :vc => version_code

    url = URI(message.payload.buyResponse.purchaseStatusResponse.appDeliveryData.downloadUrl)
    cookie = message.payload.buyResponse.purchaseStatusResponse.appDeliveryData.downloadAuthCookie[0]

    resp = recursive_apk_fetch(url, cookie)

    return resp.body

  end
  
end