# Patch for 1.1.5
ApkDownloader::Api.class_eval do

  LoginUri = URI('https://android.clients.google.com/auth')
  GoogleApiUri = URI('https://android.clients.google.com/fdfe')

  # def initialize(android_id, email, password, proxy_ip, proxy_port, user_agent)
  #   @android_id, @email, @password, @proxy_ip, @proxy_port, @user_agent = android_id, email, password, proxy_ip, proxy_port, user_agent
  #   puts "#@proxy_ip: #{@proxy_ip}"
  #   @details_messages = {}
  # end

  def initialize(android_id, proxy_ip, proxy_port, user_agent, auth_token)
    @android_id, @proxy_ip, @proxy_port, @user_agent, @auth_token = android_id, proxy_ip, proxy_port, user_agent, auth_token
    puts "#@proxy_ip: #{@proxy_ip}"
    @details_messages = {}
  end

  def log_in!
    return if self.logged_in?

    headers = {
      'Accept-Encoding' => ''
    }

    params = {
      'Email' => @email,
      'Passwd' => @password,
      'service' => 'androidmarket',
      'accountType' => 'HOSTED_OR_GOOGLE',
      'has_permission' => '1',
      'source' => 'android',
      'androidId' => @android_id,
      'app' => 'com.android.vending',
      'device_country' => 'us',
      'operatorCountry' => 'us',
      'lang' => 'en',
      # 'sdk_version' => '17'
      'sdk_version' => '22'
    }

    response = res(type: :post, req: {host: LoginUri.host, path: LoginUri.path, protocol: "https", headers: headers}, params: params)

    status_code = response.status

    if response.status != 200
      fail ApkDownloader::UnableToLogIn.new("Unable to connect with Google | status_code: #{status_code}", status_code: status_code)
    elsif response.body.include? "Auth="
      @auth_token = response.body.scan(/Auth=(.*?)$/).flatten.first
    else
      fail ApkDownloader::NoAuthToken # may not need auth token... see when this is actually raised
    end

  end

  def details package
      if @details_messages[package].nil?
        log_in!
        message, status_code = api_request :get, '/details', :doc => package # patch: return status code too
        @details_messages[package] = message.payload
      end

      return @details_messages[package]
  end

  def fetch_apk_data package
    # log_in!

    puts "@auth_token: #{@auth_token}"

    doc = details(package).detailsResponse.docV2
    version_code = doc.details.appDetails.versionCode
    offer_type = doc.offer[0].offerType

    message, status_code = api_request :post, '/purchase', :ot => offer_type, :doc => package, :vc => version_code

    url = URI(message.payload.buyResponse.purchaseStatusResponse.appDeliveryData.downloadUrl)
    cookie = message.payload.buyResponse.purchaseStatusResponse.appDeliveryData.downloadAuthCookie[0]

    message = "Google did not return url or cookie | status_code: #{status_code}"

    fail ApkDownloader::NoApkDataUrl.new(message, status_code: status_code) if url.blank?
    fail ApkDownloader::NoApkDataCookie.new(message, status_code: status_code) if cookie.blank?        

    resp = recursive_apk_fetch(url, cookie)

    return resp.body
  end

  private
  def recursive_apk_fetch url, cookie, first = true

    headers = {
      'Accept-Encoding' => '',
      'User-Agent' => 'AndroidDownloadManager/4.1.1 (Linux; U; Android 5.1.1; Nexus 9 Build/LMY48M)'
    }

    cookies = [cookie.name, cookie.value].join('=')

    params = url.query.split('&').map{ |q| q.split('=') }

    response = res(type: :get, req: {host: url.host, path: url.path, protocol: "https", headers: headers, cookies: cookies}, params: params)

    return recursive_apk_fetch(URI(response['Location']), cookie, false) if first

    fail EmptyRecursiveApkFetch.new("recursive_apk_fetch returned empty | status_code: #{response.status}", status_code: status_code) if response.blank?

    response 
  end

  # Get the response using a proxy
  def res(req:, params:, type:)

    proxy = "#{@proxy_ip}:#{@proxy_port}"

    response = CurbFu.send(type, req, params) do |curb|
      curb.proxy_url = proxy
      curb.ssl_verify_peer = false
      curb.max_redirects = 3
      curb.timeout = 90
    end

    if [200, 302].include?(response.status)
      return response
    else
      if response.status == 403
        status = nil
        display_type = nil

        if response.body.include? "This item cannot be installed in your country"
          status = :out_of_country
          display_type = :foreign
        elsif response.body.include? "Your device is not compatible with this item"
          status = :bad_device
        elsif response.body.include? "This item is not available on your carrier."
          status = :bad_carrier
          display_type = :carrier_incompatible
        elsif response.body.include? "The item you were attempting to purchase could not be found"
          status = :not_found
          display_type = :item_not_found
        else
          status = :forbidden
        end
      elsif response.status == 404
        display_type = :taken_down
        status = :taken_down
      end

      status_code = response.status

      if status_code == 403
        message = "#{response.body}, status code #{status_code} from #{caller[0][/`.*'/][1..-2]} on #{@proxy_ip} | status_code: #{status_code}"
        fail ApkDownloader::Response403.new(message, status: status, display_type: display_type, status_code: status_code)
      else
        message = "status code #{status_code} from #{caller[0][/`.*'/][1..-2]} on #{@proxy_ip} | status_code: #{status_code}"
        if status_code == 404
          fail ApkDownloader::Response404.new(message, status: status, display_type: display_type, status_code: status_code)
        elsif status_code == 500
          fail ApkDownloader::Response500.new(message, status_code: status_code)
        else
          fail ApkDownloader::ResponseOther.new(response.body)
        end
      end

    end

  end

  def api_request type, path, data = {}
    puts "@auth_token: #{@auth_token}"
    puts "@android_id: #{@android_id}"
    puts "@user_agent: #{@user_agent}"

    headers = {
      'Accept-Language' => 'en_US',
      'Authorization' => "GoogleLogin auth=#{@auth_token}",
      'X-DFE-Enabled-Experiments' => 'cl:billing.select_add_instrument_by_default',
      'X-DFE-Unsupported-Experiments' => 'nocache:billing.use_charging_poller,market_emails,buyer_currency,prod_baseline,checkin.set_asset_paid_app_field,shekel_test,content_ratings,buyer_currency_in_app,nocache:encrypted_apk,recent_changes',
      'X-DFE-Device-Id' => @android_id,
      'X-DFE-Client-Id' => 'am-android-google',
      # 'User-Agent' => 'Android-Finsky/5.8.8 (api=3,versionCode=80380800,sdk=22,device=flounder,hardware=flounder,product=volantis,platformVersionRelease=5.1.1,model=Nexus%209,buildId=LMY48M,isWideScreen=1)',
      'User-Agent' => @user_agent,
      'X-DFE-SmallestScreenWidthDp' => '320',
      'X-DFE-Filter-Level' => '3',
      'Accept-Encoding' => '',
      'Host' => 'android.clients.google.com'
    }

    headers['Content-Type'] = 'application/x-www-form-urlencoded; charset=UTF-8' if type == :post

    uri = URI([GoogleApiUri,path.sub(/^\//,'')].join('/'))

    response = res(type: type, req: {:host => uri.host, :path => uri.path, :protocol => "https", :headers => headers}, params: data)

    return ApkDownloader::ProtocolBuffers::ResponseWrapper.new.parse(response.body), response.status

  end

end
