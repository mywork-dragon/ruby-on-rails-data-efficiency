module MightyApk
  class MarketApi
    class MarketError < RuntimeError; end

    class NotFound < MarketError; end
    class Unauthorized < MarketError; end
    class Forbidden < MarketError; end
    class InternalError < MarketError; end
    class UnknownCondition < MarketError; end
    class UnsupportedCountry < MarketError; end
    class RateLimited < MarketError; end
    class IncompatibleDevice < MarketError; end

    include HTTParty
    include ProxyParty

    base_uri 'https://android.clients.google.com/fdfe'

    def initialize(google_account)
      @google_account = google_account
    end

    def validate(httparty_res)
      raise Unauthorized if httparty_res.code == 401
      handle_forbidden(httparty_res) if httparty_res.code == 403
      handle_not_found(httparty_res) if httparty_res.code == 404
      raise RateLimited if httparty_res.code == 429
      raise InternalError if httparty_res.code == 500
      unless httparty_res.code / 200 == 1 # non-200 level code
        raise UnknownCondition, "#{httparty_res.code}: #{httparty_res.body}"
      end
      raw_resp = MightyApk::ProtocolBuffers::ResponseWrapper.new.parse(httparty_res.body)
      GooglePlayDeviceApiService.parse_attributes(raw_resp) #Throws error if missing fields      
    end

    def bulk_details(app_identifiers, childDocs: false)
      data = MightyApk::ProtocolBuffers::BulkDetailsRequest
        .new(docid: app_identifiers, includeChildDocs: childDocs)
        .serialize_to_string
      res = self.class.proxy_request do
        self.class.post(
          '/bulkDetails',
          params: { 'au' => '1' },
          body: data,
          headers: api_request_headers.merge({ 'Content-Type' => 'application/x-protobuf' })
        )
      end
      validate(res)
      res
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

    def other(link, query)
      res = self.class.proxy_request(proxy_type: :android_classification) do
        self.class.get(
          '/' + link,
          headers: api_request_headers,
          query: query
        )
      end
      res
    end

    def purchase(app_identifier, offer_type, version_code)
      begin
        self.class.try_all_regions do |region|
          req_headers = api_request_headers.merge(
            'Content-Type' => 'application/x-www-form-urlencoded; charset=UTF-8'
          )
          res = self.class.proxy_request(proxy_type: :android_classification, region: region) do
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
          [res, region]
        end
      rescue ProxyParty::AllRegionsFailed
        raise UnsupportedCountry
      end
    end

    def deliver(app_identifier, offer_type, version_code, dtok, server_token)
      res = self.class.proxy_request(proxy_type: :android_classification) do
        self.class.get(
          '/delivery',
          headers: api_request_headers,
          query: {
            ot: offer_type,
            vc: version_code,
            doc: app_identifier,
            st: Base64.encode64(server_token).strip,
            dtok: dtok
          })
      end
      validate(res)
      res
    end

    # uses open-uri instead of HTTParty because result was not readable by ruby_apk gem
    def download(download_url, cookie, destination, region)
      if cookie.present?
        headers = fetch_headers(cookie.name, cookie.value)
      else
        headers = api_request_headers
      end

      headers = {}.merge(
        ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE
      )
      begin
        proxy_info = self.class.select_proxy(proxy_type: :android_classification, region: region)
        proxy_uri = "http://#{proxy_info[:ip]}:#{proxy_info[:port]}"
        if proxy_info[:user].present?
          headers.merge({ :proxy_http_basic_authentication => [proxy_uri, proxy_info[:user], proxy_info[:password]]})
        else
          headers.merge({ proxy: proxy_uri })
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
    rescue ProxyParty::UnsupportedRegion
      raise UnsupportedCountry
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

    def handle_not_found(res)
      if res.nil?
        return
      end
      body = res.body
      raise ProxyParty::UnsupportedRegion if body.match(/not.*supported.*country/i)
      raise IncompatibleDevice if body.match(/Your device is not compatible with this item/i)
      raise NotFound
    end

    def handle_forbidden(res)
      body = res.body
      raise ProxyParty::UnsupportedRegion if body.match(/not.*supported.*country/i)
      raise IncompatibleDevice if body.match(/Your device is not compatible with this item/i)
      raise Forbidden
    end
  end
end
