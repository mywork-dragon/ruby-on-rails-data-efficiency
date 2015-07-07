# Patch for 1.1.5
if defined?(ApkDownloader)

  ApkDownloader::Api.module_eval do

    LoginUri = URI('https://android.clients.google.com/auth')
    GoogleApiUri = URI('https://android.clients.google.com/fdfe')

    attr_reader :auth_token, :ip

    def fetch_apk_data package

      if Rails.env.production?
        proxy = Tor.next_proxy_old
        proxy.last_used = DateTime.now
        @ip = proxy.private_ip
        proxy.save
      elsif Rails.env.development?
        @ip = '127.0.0.1'
      end

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

    def use_tor(host, port)
      Net::HTTP.SOCKSProxy(@ip, 9050).new(host, port)
    end

    def log_in!
      return if self.logged_in?

      params = {
        "Email" => ApkDownloader.configuration.email,
        "Passwd" => ApkDownloader.configuration.password,
        "service" => "androidmarket",
        "accountType" => "HOSTED_OR_GOOGLE",
        "has_permission" => "1",
        "source" => "android",
        "androidId" => ApkDownloader.configuration.android_id,
        "app" => "com.android.vending",
        "device_country" => "fr",
        "operatorCountry" => "fr",
        "lang" => "fr",
        "sdk_version" => "16"
      }

      # login_http = Net::HTTP.new LoginUri.host, LoginUri.port

      host = LoginUri.host
      port = LoginUri.port

      login_http = use_tor(host, port)
      login_http.use_ssl = true
      login_http.ssl_version="SSLv3"
      login_http.verify_mode  = OpenSSL::SSL::VERIFY_NONE

      post = Net::HTTP::Post.new LoginUri.to_s
      post.set_form_data params
      post["Accept-Encoding"] = ""

      response = login_http.request post

      if ApkDownloader.configuration.debug
        # pp "Login response:"
        # pp response
      end

      if response.body =~ /error/i
        raise "Unable to authenticate with Google"
      elsif response.body.include? "Auth="
        @auth_token = response.body.scan(/Auth=(.*?)$/).flatten.first
      end
    end


    private
    def recursive_apk_fetch url, cookie, tries = 5
      raise ArgumentError, 'HTTP redirect too deep' if tries == 0

      # http = Net::HTTP.new url.host, url.port
      host = url.host
      port = url.port

      http = use_tor(host, port)
      http.use_ssl = (url.scheme == 'https')
      http.ssl_version="SSLv3"
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      req = Net::HTTP::Get.new url.to_s
      req['Accept-Encoding'] = ''
      req['User-Agent'] = 'AndroidDownloadManager/4.1.1 (Linux; U; Android 4.1.1; Nexus S Build/JRO03E)'
      req['Cookie'] = [cookie.name, cookie.value].join('=')

      resp = http.request req

      case resp
      when Net::HTTPSuccess
        return resp
      when Net::HTTPRedirection
        return recursive_apk_fetch(URI(resp['Location']), cookie, tries - 1)
      else
        resp.error!
      end

    end

    def api_request type, path, data = {}
      if @http.nil?
        # @http = Net::HTTP.new GoogleApiUri.host, GoogleApiUri.port
        host = GoogleApiUri.host
        port = GoogleApiUri.port

        @http = use_tor(host, port)
        @http.use_ssl = true
        @http.ssl_version="SSLv3"
        @http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end

      api_headers = {
        "Accept-Language" => "en_US",
        "Authorization" => "GoogleLogin auth=#{@auth_token}",
        "X-DFE-Enabled-Experiments" => "cl:billing.select_add_instrument_by_default",
        "X-DFE-Unsupported-Experiments" => "nocache:billing.use_charging_poller,market_emails,buyer_currency,prod_baseline,checkin.set_asset_paid_app_field,shekel_test,content_ratings,buyer_currency_in_app,nocache:encrypted_apk,recent_changes",
        "X-DFE-Device-Id" => ApkDownloader.configuration.android_id,
        "X-DFE-Client-Id" => "am-android-google",
        "User-Agent" => "Android-Finsky/3.7.13 (api=3,versionCode=8013013,sdk=16,device=crespo,hardware=herring,product=soju)",
        "X-DFE-SmallestScreenWidthDp" => "320",
        "X-DFE-Filter-Level" => "3",
        "Accept-Encoding" => "",
        "Host" => "android.clients.google.com"
      }

      if type == :post
        api_headers['Content-Type'] = 'application/x-www-form-urlencoded; charset=UTF-8'
      end

      uri = URI([GoogleApiUri,path.sub(/^\//,'')].join('/'))

      req = if type == :get
        uri.query = URI.encode_www_form data
        Net::HTTP::Get.new uri.to_s
      else
        post = Net::HTTP::Post.new uri.to_s
        post.tap { |p| p.set_form_data data }
      end

      api_headers.each { |k, v| req[k] = v }

      resp = @http.request req

      unless resp.code.to_i == 200 or resp.code.to_i == 302
        raise "Bad status (#{resp.code}) from Play API (#{path}) => #{data}"
      end

      if ApkDownloader.configuration.debug
        pp "Request response (#{type}):"
        pp resp
      end

      return ApkDownloader::ProtocolBuffers::ResponseWrapper.new.parse(resp.body)
    end

  end
end