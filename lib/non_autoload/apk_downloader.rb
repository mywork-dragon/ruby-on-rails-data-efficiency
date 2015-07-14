# Patch for 1.1.5
if defined?(ApkDownloader)

  ApkDownloader::Api.module_eval do

    LoginUri = URI('https://android.clients.google.com/auth')
    GoogleApiUri = URI('https://android.clients.google.com/fdfe')

    attr_reader :auth_token, :ip

    def log_in!
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

      response = CurbFu.post({:host => LoginUri.host, :path => LoginUri.path, :protocol => "https", :headers => headers}, params) do |curb|
        curb.proxy_url = @proxy
        curb.ssl_verify_peer = false
        curb.max_redirects = 3
      end

      if response.body =~ /error/i
        raise "Unable to authenticate with Google"
      elsif response.body.include? "Auth="
        @auth_token = response.body.scan(/Auth=(.*?)$/).flatten.first
      end

    end

    def fetch_apk_data package

      if Rails.env.production?

        # SuperProxy.transaction do
        #   p = SuperProxy.lock.order(last_used: :asc).first
        #   @proxy_ip = p.private_ip
        #   @proxy_port = p.port
        #   p.last_used = DateTime.now
        #   p.save
        # end

        @proxy = "#{get_ip}/8888"

      elsif Rails.env.development?
        ip = '127.0.0.1'
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

    def get_ip
      %w(
        172.31.20.1
        172.31.29.18
        172.31.20.230
        172.31.24.153
        172.31.24.26
        172.31.37.27
        172.31.36.192
        172.31.36.118
        172.31.32.44
        172.31.36.248
      ).sample
    end

    private
    def recursive_apk_fetch url, cookie, try = 0

      headers = {
        'Accept-Encoding' => '',
        'User-Agent' => 'AndroidDownloadManager/4.1.1 (Linux; U; Android 4.1.1; Nexus S Build/JRO03E)'
      }

      cookies = [cookie.name, cookie.value].join('=')

      params = url.query.split('&').map{ |q| q.split('=') }

      response = CurbFu.get({:host => url.host, :path => url.path, :protocol => "https", :headers => headers, :cookies => cookies}, params) do |curb|
        curb.proxy_url = @proxy
        curb.ssl_verify_peer = false
        curb.max_redirects = 5
      end

      if try==0
        return recursive_apk_fetch(URI(response['Location']), cookie, try + 1)
      elsif try==1
        return response
      end
        
    end

    def api_request type, path, data = {}

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

      if type == :get
        response = CurbFu.get({:host => uri.host, :path => uri.path, :protocol => "https", :headers => headers}, data) do |curb|
          curb.proxy_url = @proxy
          curb.ssl_verify_peer = false
          curb.max_redirects = 3
        end
      elsif type == :post
        response = CurbFu.post({:host => uri.host, :path => uri.path, :protocol => "https", :headers => headers}, data) do |curb|
          curb.proxy_url = @proxy
          curb.ssl_verify_peer = false
          curb.max_redirects = 3
        end
      end

      return ApkDownloader::ProtocolBuffers::ResponseWrapper.new.parse(response.body)
    end

  end
end