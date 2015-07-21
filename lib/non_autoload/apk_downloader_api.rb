# Patch for 1.1.5
if defined?(ApkDownloader)

  ApkDownloader::Api.module_eval do

    LoginUri = URI('https://android.clients.google.com/auth')
    GoogleApiUri = URI('https://android.clients.google.com/fdfe')

    attr_reader :auth_token, :ip

    def log_in!(proxy_ip, proxy_port, apk_snap_id, package)
      return if self.logged_in?

      headers = {
        'Accept-Encoding' => ''
      }

      ga = GoogleAccount.joins(apk_snapshots: :google_account).where('apk_snapshots.id = ?', apk_snap_id).first

      params = {
        'Email' => ga.email,
        'Passwd' => ga.password,
        'service' => 'androidmarket',
        'accountType' => 'HOSTED_OR_GOOGLE',
        'has_permission' => '1',
        'source' => 'android',
        'androidId' => ga.android_identifier,
        'app' => 'com.android.vending',
        'device_country' => 'fr',
        'operatorCountry' => 'fr',
        'lang' => 'fr',
        'sdk_version' => '16'
      }

      # response = res(type: :post, req: {:host => LoginUri.host, :path => LoginUri.path, :protocol => "https", :headers => headers}, params: params, proxy_ip: proxy_ip, proxy_port: proxy_port)

      response = res_net(type: :post, uri: LoginUri, headers: headers, params: params, proxy_ip: proxy_ip, proxy_port: proxy_port)

      if response.body =~ /error/i
        ApkSnapshotException.create(name: "ERROR! - account: #{ga.email}, account_id: #{ga.id}, package: #{package}")
        raise "Unable to authenticate with Google"
      elsif response.body.include? "Auth="
        auth_token = response.body.scan(/Auth=(.*?)$/).flatten.first
        ApkSnapshotException.create(name: "auth_token: #{auth_token}, account: #{ga.email}, account_id: #{ga.id}, package: #{package}")
        return auth_token
      end

    end

    def details package, auth_token, proxy_ip, proxy_port, apk_snap_id
      if @details_messages[package].nil?
        log_in!(proxy_ip, proxy_port, apk_snap_id, package)
        message = api_request auth_token, proxy_ip, proxy_port, :get, '/details', :doc => package
        @details_messages[package] = message.payload
      end

      return @details_messages[package]
    end

    def fetch_apk_data package, apk_snap_id

      mp = MicroProxy.transaction do

        p = MicroProxy.lock.order(last_used: :asc).first
        p.last_used = DateTime.now
        p.save

        apk_snap = ApkSnapshot.find_by_id(apk_snap_id)
        apk_snap.proxy = p.private_ip
        apk_snap.save

      end

      if mp

        snap = ApkSnapshot.find_by_id(apk_snap_id)

        proxy_ip = snap.proxy
        proxy_port = "8888"

        auth_token = log_in!(proxy_ip, proxy_port, apk_snap_id, package)
        doc = details(package, auth_token, proxy_ip, proxy_port, apk_snap_id).detailsResponse.docV2
        version_code = doc.details.appDetails.versionCode
        offer_type = doc.offer[0].offerType

        message = api_request auth_token, proxy_ip, proxy_port, :post, '/purchase', :ot => offer_type, :doc => package, :vc => version_code

        url = URI(message.payload.buyResponse.purchaseStatusResponse.appDeliveryData.downloadUrl)
        cookie = message.payload.buyResponse.purchaseStatusResponse.appDeliveryData.downloadAuthCookie[0]

        if url.blank? || cookie.blank?
          snap.status = :no_response
          snap.save
          raise "Google did not return url or cookie"
        end

        resp = recursive_apk_fetch(proxy_ip, proxy_port, url, cookie)

        return resp.body

      else

        raise 'could not find ip to use'

      end

    end

    private
    def recursive_apk_fetch proxy_ip, proxy_port, url, cookie, first = true

      headers = {
        'Accept-Encoding' => '',
        'User-Agent' => 'AndroidDownloadManager/4.1.1 (Linux; U; Android 4.1.1; Nexus S Build/JRO03E)'
      }

      cookies = [cookie.name, cookie.value].join('=')

      params = url.query.split('&').map{ |q| q.split('=') }

      # response = res(type: :get, req: {:host => url.host, :path => url.path, :protocol => "https", :headers => headers, :cookies => cookies}, params: params, proxy_ip: proxy_ip, proxy_port: proxy_port)

      response = res_net(type: :get, uri: url, headers: headers, params: params, proxy_ip: proxy_ip, proxy_port: proxy_port)

      return recursive_apk_fetch(proxy_ip, proxy_port, URI(response['Location']), cookie, false) if first

      response
        
    end


    def res(req:, params:, type:, proxy_ip:, proxy_port:)

      proxy = "#{proxy_ip}:#{proxy_port}"

      type = type.to_sym

      raise 'type is not get or post' unless [:get,:post].include? type

      response = CurbFu.send(type, req, params) do |curb|
        curb.proxy_url = proxy
        curb.ssl_verify_peer = false
        curb.max_redirects = 3
      end

    end

    # def res_net(type: :get, uri: URI("https://www.google.com/search"), headers: {'Accept-Encoding' => ''}, params: {"q"=>"asdf"}, proxy_ip: '', proxy_port: '')

    def res_net(type:, uri:, headers:, params:, proxy_ip:, proxy_port:)

      http = Net::HTTP.new uri.host, uri.port
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      if type == :post
        req = Net::HTTP::Post.new uri.to_s
        req.set_form_data params
      elsif type == :get
        uri.query = URI.encode_www_form params
        req = Net::HTTP::Get.new uri.to_s
      end

      headers.each{|k,v| req[k] = v}

      res = http.request req

    end

    def api_request auth_token, proxy_ip, proxy_port, type, path, data = {}

      headers = {
        'Accept-Language' => 'en_US',
        'Authorization' => "GoogleLogin auth=#{auth_token}",
        'X-DFE-Enabled-Experiments' => 'cl:billing.select_add_instrument_by_default',
        'X-DFE-Unsupported-Experiments' => 'nocache:billing.use_charging_poller,market_emails,buyer_currency,prod_baseline,checkin.set_asset_paid_app_field,shekel_test,content_ratings,buyer_currency_in_app,nocache:encrypted_apk,recent_changes',
        'X-DFE-Device-Id' => ApkDownloader.configuration.android_id,
        'X-DFE-Client-Id' => 'am-android-google',
        'User-Agent' => 'Android-Finsky/3.7.13 (api=3,versionCode=8013013,sdk=16,device=crespo,hardware=herring,product=soju)',
        'X-DFE-SmallestScreenWidthDp' => '320',
        'X-DFE-Filter-Level' => '3',
        'Accept-Encoding' => '',
        'Host' => 'android.clients.google.com'
      }

      headers['Content-Type'] = 'application/x-www-form-urlencoded; charset=UTF-8' if type == :post

      uri = URI([GoogleApiUri,path.sub(/^\//,'')].join('/'))

      # response = res(type: type, req: {:host => uri.host, :path => uri.path, :protocol => "https", :headers => headers}, params: data, proxy_ip: proxy_ip, proxy_port: proxy_port)

      response = res_net(type: type, uri: uri, headers: headers, params: data, proxy_ip: proxy_ip, proxy_port: proxy_port)

      return ApkDownloader::ProtocolBuffers::ResponseWrapper.new.parse(response.body)
    end

  end
end