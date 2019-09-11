# for interfacing with the Google Play Market on behalf of an Android user
module MightyApk
  class Market
    def initialize(google_account)
      @api = MarketApi.new(google_account)
    end

    def save_permissions_to_hotstore(app_identifier, details)
      begin
        app = AndroidApp.find_by_app_identifier!(app_identifier)
        if details.details.appDetails.permission
          AppHotStore.new.write_attribute(
            app.id,
            app.app_identifier, app.platform, 'permissions', details.details.appDetails.permission)
        end
      rescue => e
        Bugsnag.notify(e)
      end
    end

    def app_details(app_identifier)
      raw_app_details(app_identifier).payload.detailsResponse.docV2
    end

    def raw_app_details(app_identifier)
      resp = @api.details(app_identifier)
      raw_details = MightyApk::ProtocolBuffers::ResponseWrapper.new.parse(resp.body)
      save_permissions_to_hotstore(app_identifier, raw_details.payload.detailsResponse.docV2)
      raw_details
    end

    def bulk_details(app_identifiers)
      resp = @api.bulk_details(app_identifiers)
      MightyApk::ProtocolBuffers::ResponseWrapper
        .new.parse(resp.body)
    end

    def other(link, query = {})
      MightyApk::ProtocolBuffers::ResponseWrapper
        .new.parse(@api.other(link, query).body)
    end

    # assumes app is free...should verify?
    def purchase!(app_identifier, offer_type, version_code)
      # Returns [MightyApk::ProtocolBuffers::ResponseWrapper, region]
      purchase_info, region = @api.purchase(app_identifier, offer_type, version_code)
      [MightyApk::ProtocolBuffers::ResponseWrapper
        .new.parse(purchase_info.body)
        .payload.buyResponse, region]
    end

    def deliver!(app_identifier, offer_type, version_code, dtok, server_token)
      delivery_info = @api.deliver(app_identifier, offer_type, version_code, dtok, server_token)
      MightyApk::ProtocolBuffers::ResponseWrapper.new.parse(delivery_info.body).payload.deliveryResponse
    end

    def download!(app_identifier, destination)
      # Returns the region which this apk was downloaded in
      app = app_details(app_identifier)
      offer_type = app.offer[0].offerType
      version_code = app.details.appDetails.versionCode

      purchase_info, region = purchase!(app_identifier, offer_type, version_code)

      cookie = purchase_info.purchaseStatusResponse.appDeliveryData.downloadAuthCookie[0]
      download_url = purchase_info.purchaseStatusResponse.appDeliveryData.downloadUrl

      if region != nil
        Rails.logger.info "Downloading #{app_identifier} in #{region}"
      end

      if ! download_url.present?
        server_token = purchase_info.purchaseStatusResponse.libraryUpdate.serverToken
        dtok = purchase_info.dtok
        delivery_info = deliver!(app_identifier, offer_type, version_code, dtok, server_token)
        download_url = delivery_info.appDeliveryData.downloadUrl
      end
      @api.download(download_url, cookie, destination, region)
      region
    end
  end
end
