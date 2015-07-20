# Patch for 1.1.5
if defined?(ApkDownloader)

  ApkDownloader::Api.module_eval do

    LoginUri = URI('https://android.clients.google.com/auth')
    GoogleApiUri = URI('https://android.clients.google.com/fdfe')

    attr_reader :auth_token, :ip

    def log_in!(proxy)
      return if self.logged_in?

      headers = {
        'Accept-Encoding' => ''
      }

      params = {
        'Email' => ApkDownloader.configuration.email,
        'Passwd' => ApkDownloader.configuration.password,
        'service' => 'androidmarket',
        'accountType' => 'HOSTED_OR_GOOGLE',
        'has_permission' => '1',
        'source' => 'android',
        'androidId' => ApkDownloader.configuration.android_id,
        'app' => 'com.android.vending',
        'device_country' => 'fr',
        'operatorCountry' => 'fr',
        'lang' => 'fr',
        'sdk_version' => '16'
      }

      response = res(type: :post, req: {:host => LoginUri.host, :path => LoginUri.path, :protocol => "https", :headers => headers}, params: params, proxy: proxy)

      if response.body =~ /error/i
        raise "Unable to authenticate with Google"
      elsif response.body.include? "Auth="
        @auth_token = response.body.scan(/Auth=(.*?)$/).flatten.first
      end

    end

    def details package, proxy
      if @details_messages[package].nil?
        log_in!(proxy)
        message = api_request proxy, :get, '/details', :doc => package
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

        ip = ApkSnapshot.find_by_id(apk_snap_id).proxy

        proxy = "#{ip}:8888"

        log_in!(proxy)
        doc = details(package, proxy).detailsResponse.docV2
        version_code = doc.details.appDetails.versionCode
        offer_type = doc.offer[0].offerType

        message = api_request proxy, :post, '/purchase', :ot => offer_type, :doc => package, :vc => version_code

        url = URI(message.payload.buyResponse.purchaseStatusResponse.appDeliveryData.downloadUrl)
        cookie = message.payload.buyResponse.purchaseStatusResponse.appDeliveryData.downloadAuthCookie[0].strip

        ApkSnapshotException.create(name: "url: #{url}\ncookie: #{cookie}\nproxy: #{proxy}")

        raise "Google did not return url or cookie" if url.blank? || cookie.blank?

        resp = recursive_apk_fetch(proxy, url, cookie)

        return resp.body

      else

        raise 'could not find ip to use'

      end

    end

    private
    def recursive_apk_fetch proxy, url, cookie, first = true

      headers = {
        'Accept-Encoding' => '',
        'User-Agent' => 'AndroidDownloadManager/4.1.1 (Linux; U; Android 4.1.1; Nexus S Build/JRO03E)'
      }

      cookies = [cookie.name, cookie.value].join('=')

      params = url.query.split('&').map{ |q| q.split('=') }

      response = res(type: :get, req: {:host => url.host, :path => url.path, :protocol => "https", :headers => headers, :cookies => cookies}, params: params, proxy: proxy)

      return recursive_apk_fetch(proxy, URI(response['Location']), cookie, false) if first

      response
        
    end

    def res(req:, params:, type:, proxy:)

      type = type.to_sym

      raise 'type is not get or post' unless [:get,:post].include? type

      response = CurbFu.send(type, req, params) do |curb|
        curb.proxy_url = proxy
        curb.ssl_verify_peer = false
        curb.max_redirects = 3
      end

    end

    def api_request proxy, type, path, data = {}

      headers = {
        'Accept-Language' => 'en_US',
        'Authorization' => "GoogleLogin auth=#{@auth_token}",
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

      response = res(type: type, req: {:host => uri.host, :path => uri.path, :protocol => "https", :headers => headers}, params: data, proxy: proxy)

      return ApkDownloader::ProtocolBuffers::ResponseWrapper.new.parse(response.body)
    end

  end
end