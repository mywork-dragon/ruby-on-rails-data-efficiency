# Patch for 1.1.5
if defined?(ApkDownloader)

  ApkDownloader::Api.module_eval do

    LoginUri = URI('https://android.clients.google.com/auth')
    GoogleApiUri = URI('https://android.clients.google.com/fdfe')

    def log_in!(proxy_ip, proxy_port, apk_snap_id)
      # return if self.logged_in?

      # ga = GoogleAccount.joins(apk_snapshots: :google_account).where('apk_snapshots.id = ?', apk_snap_id).first

      # if self.logged_in?
      #   ApkSnapshotException.create(name: "old: #{@auth_token}\naccount: #{ga.email}")
      #   return
      # end

      snap = ApkSnapshot.find_by_id(apk_snap_id)

      return if snap.auth_token.present?

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

      response = res(type: :post, req: {:host => LoginUri.host, :path => LoginUri.path, :protocol => "https", :headers => headers}, params: params, proxy_ip: proxy_ip, proxy_port: proxy_port, apk_snap_id: apk_snap_id)

      if response.status != 200
        # raise "Unable to authenticate with Google | status_code: #{response.status}"
        raise "Unable to connect with Google | status_code: #{response.status}"
      elsif response.body.include? "Auth="
        # @auth_token = response.body.scan(/Auth=(.*?)$/).flatten.first
        a = response.body.scan(/Auth=(.*?)$/).flatten.first
        snap.auth_token = a
        snap.save
        # ApkSnapshotException.create(name: "new: #{@auth_token}\naccount: #{ga.email}")
      end

    end

    def details package, proxy_ip, proxy_port, apk_snap_id
      if @details_messages[package].nil?
        log_in!(proxy_ip, proxy_port, apk_snap_id)
        status_code, message = api_request apk_snap_id, proxy_ip, proxy_port, :get, '/details', :doc => package
        @details_messages[package] = message.payload
      end

      return @details_messages[package]
    end

    def fetch_apk_data package, apk_snap_id

      # @auth_token = nil

      mp = MicroProxy.transaction do

        p = MicroProxy.lock.order(last_used: :asc).first
        p.last_used = DateTime.now
        p.save

        p

      end

      apk_snap = ApkSnapshot.find_by_id(apk_snap_id)
      apk_snap.proxy = mp.private_ip
      apk_snap.save
      
      proxy_ip = mp.private_ip
      proxy_port = "8888"

      log_in!(proxy_ip, proxy_port, apk_snap_id)

      # if @auth_token.blank?

      #   raise "auth_token was blank"

      # else

      #   apk_snap.auth_token = @auth_token

      # end

      # apk_snap.save

      doc = details(package, proxy_ip, proxy_port, apk_snap_id).detailsResponse.docV2
      version_code = doc.details.appDetails.versionCode
      offer_type = doc.offer[0].offerType

      status_code, message = api_request apk_snap_id, proxy_ip, proxy_port, :post, '/purchase', :ot => offer_type, :doc => package, :vc => version_code

      url = URI(message.payload.buyResponse.purchaseStatusResponse.appDeliveryData.downloadUrl)
      cookie = message.payload.buyResponse.purchaseStatusResponse.appDeliveryData.downloadAuthCookie[0]

      if url.blank? || cookie.blank? || proxy_ip.blank?
        snap = ApkSnapshot.find_by_id(apk_snap_id)
        snap.status = :no_response
        snap.save
        raise "Google did not return url or cookie | status_code: #{status_code}"
      end

      resp = recursive_apk_fetch(apk_snap_id, proxy_ip, proxy_port, url, cookie)

      return resp.body

    end

    private
    def recursive_apk_fetch apk_snap_id, proxy_ip, proxy_port, url, cookie, first = true

      headers = {
        'Accept-Encoding' => '',
        'User-Agent' => 'AndroidDownloadManager/4.1.1 (Linux; U; Android 4.1.1; Nexus S Build/JRO03E)'
      }

      cookies = [cookie.name, cookie.value].join('=')

      params = url.query.split('&').map{ |q| q.split('=') }

      response = res(type: :get, req: {:host => url.host, :path => url.path, :protocol => "https", :headers => headers, :cookies => cookies}, params: params, proxy_ip: proxy_ip, proxy_port: proxy_port, apk_snap_id: apk_snap_id)

      return recursive_apk_fetch(apk_snap_id, proxy_ip, proxy_port, URI(response['Location']), cookie, false) if first

      if response.blank?

        as = ApkSnapshot.find_by_id(apk_snap_id)
        as.status = :failure
        as.save

        raise "recursive_apk_fetch returned empty | status_code: #{response.status}"
        
      end

      response
        
    end

    # Testing curl
    # r = res(type: :get, req: {:host => "ip.jsontest.com", :protocol => "http"}, params: {}, proxy_ip: '172.31.29.18', proxy_port: '8888')

    def res(req:, params:, type:, proxy_ip:, proxy_port:, apk_snap_id:)

      proxy = "#{proxy_ip}:#{proxy_port}"

      response = CurbFu.send(type, req, params) do |curb|
        curb.proxy_url = proxy
        curb.ssl_verify_peer = false
        curb.max_redirects = 3
        curb.timeout = 90
      end

      # [404,403,408,503]

      if [200,302,500].include? response.status
        return response
      else
        if response.status == 403

          ga = GoogleAccount.joins(apk_snapshots: :google_account).where('apk_snapshots.id = ?', apk_snap_id).first
          ga.flags = ga.flags + 1
          ga.save

          as = ApkSnapshot.find_by_id(apk_snap_id).android_app.newest_android_app_snapshot
          as.apk_access_forbidden = true
          as.save

          snap = ApkSnapshot.find_by_id(apk_snap_id)
          snap.status = :forbidden
          snap.save

        elsif response.status == 404

          as = ApkSnapshot.find_by_id(apk_snap_id).android_app
          as.taken_down = true
          as.save

          snap = ApkSnapshot.find_by_id(apk_snap_id)
          snap.status = :taken_down
          snap.save

        else
          raise "status code #{response.status} from #{caller[0][/`.*'/][1..-2]} on #{proxy_ip} | status_code: #{response.status}"
        end
      end


    end

    def api_request apk_snap_id, proxy_ip, proxy_port, type, path, data = {}

      ga = GoogleAccount.joins(apk_snapshots: :google_account).where('apk_snapshots.id = ?', apk_snap_id).first

      auth_token = ApkSnapshot.find_by_id(apk_snap_id).auth_token

      headers = {
        'Accept-Language' => 'en_US',
        'Authorization' => "GoogleLogin auth=#{auth_token}",
        'X-DFE-Enabled-Experiments' => 'cl:billing.select_add_instrument_by_default',
        'X-DFE-Unsupported-Experiments' => 'nocache:billing.use_charging_poller,market_emails,buyer_currency,prod_baseline,checkin.set_asset_paid_app_field,shekel_test,content_ratings,buyer_currency_in_app,nocache:encrypted_apk,recent_changes',
        'X-DFE-Device-Id' => ga.android_identifier,
        'X-DFE-Client-Id' => 'am-android-google',
        'User-Agent' => 'Android-Finsky/3.7.13 (api=3,versionCode=8013013,sdk=16,device=crespo,hardware=herring,product=soju)',
        'X-DFE-SmallestScreenWidthDp' => '320',
        'X-DFE-Filter-Level' => '3',
        'Accept-Encoding' => '',
        'Host' => 'android.clients.google.com'
      }

      headers['Content-Type'] = 'application/x-www-form-urlencoded; charset=UTF-8' if type == :post

      uri = URI([GoogleApiUri,path.sub(/^\//,'')].join('/'))

      response = res(type: type, req: {:host => uri.host, :path => uri.path, :protocol => "https", :headers => headers}, params: data, proxy_ip: proxy_ip, proxy_port: proxy_port, apk_snap_id: apk_snap_id)

      return response.status, ApkDownloader::ProtocolBuffers::ResponseWrapper.new.parse(response.body)

    end

  end
end