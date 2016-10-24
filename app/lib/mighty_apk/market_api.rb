module MightyApk
  class MarketApi
    class NotFound < RuntimeError; end
    class Unauthorized < RuntimeError; end
    class Forbidden < RuntimeError; end
    class InternalError < RuntimeError; end
    class UnknownCondition < RuntimeError; end
    class UnsupportedCountry < RuntimeError; end

    include HTTParty
    include ProxyParty

    base_uri 'https://android.clients.google.com/fdfe'

    def initialize(google_account)
      @google_account = google_account
    end

    def validate(httparty_res)
      raise NotFound if httparty_res.code == 404
      raise Unauthorized if httparty_res.code == 401
      handle_forbidden(httparty_res) if httparty_res.code == 403
      raise InternalError if httparty_res.code == 500
      unless httparty_res.code / 200 == 1 # non-200 level code
        raise UnknownCondition, "#{httparty_res.code}: #{httparty_res.body}"
      end
    end

    def details(app_identifier)
      res = self.class.proxy_request(proxy_type: :android_classification) do
        self.class.get(
          '/details',
          headers: api_request_headers,
          query: { 'doc' => app_identifier }
        )
      end
      validate(res)
      res
    end

    def purchase(app_identifier, offer_type, version_code)
      req_headers = api_request_headers.merge(
        'Content-Type' => 'application/x-www-form-urlencoded; charset=UTF-8'
      )
      res = self.class.proxy_request(proxy_type: :android_classification) do
        self.class.post(
          '/purchase',
          headers: req_headers,
          query: {
            ot: offer_type,
            vc: version_code,
            doc: app_identifier
          }
        )
      end
      validate(res)
      res
    end

    # uses open-uri instead of HTTParty because result was not readable by ruby_apk gem
    def download(download_url, cookie, destination)
      headers = fetch_headers(cookie.name, cookie.value).merge(
        ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE
      )
      if Rails.env.production?
        proxy_info = self.class.select_proxy(proxy_type: :android_classification)
        headers.merge({ proxy: "http://#{proxy_info[:ip]}:#{proxy_info[:port]}" })
      end

      File.open(destination, 'wb') do |dest_fd|
        open(
          download_url,
          headers
        ) do |src_fd|
          IO.copy_stream(src_fd, dest_fd)
        end
      end
    end

    def api_request_headers
      {
        'Accept-Language' => 'en_US',
        'Authorization' => "GoogleLogin auth=#{@google_account.auth_token}",
        'X-DFE-Enabled-Experiments' => 'cl:billing.select_add_instrument_by_default',
        'X-DFE-Unsupported-Experiments' => 'nocache:billing.use_charging_poller,market_emails,buyer_currency,prod_baseline,checkin.set_asset_paid_app_field,shekel_test,content_ratings,buyer_currency_in_app,nocache:encrypted_apk,recent_changes',
        'X-DFE-Device-Id' => @google_account.android_identifier,
        'X-DFE-Client-Id' => 'am-android-google',
        'User-Agent' => @google_account.user_agent,
        'X-DFE-SmallestScreenWidthDp' => '320',
        'X-DFE-Filter-Level' => '3',
        'Accept-Encoding' => '',
        'Host' => 'android.clients.google.com'
      }
    end

    def fetch_headers(cookie_name, cookie_value)
      {
        'Accept-Encoding' => '',
        'User-Agent' => 'AndroidDownloadManager/4.1.1 (Linux; U; Android 5.1.1; Nexus 9 Build/LMY48M)',
        'Cookie' => "#{cookie_name}=#{cookie_value}"
      }
    end

    def handle_forbidden(res)
      body = res.body
      raise UnsupportedCountry if body.match(/not.*supported.*country/i)
      raise Forbidden
    end
  end
end
