# for interfacing with the Google Play Market on behalf of an Android user
module MightyApk
  class Market
    def initialize(google_account)
      @api = MarketApi.new(google_account)
    end

    def app_details(app_identifier)
      resp = @api.details(app_identifier)
      MightyApk::ProtocolBuffers::ResponseWrapper
        .new.parse(resp.body)
        .payload.detailsResponse.docV2
    end

    # assumes app is free...should verify?
    def purchase!(app_identifier)
      # Returns [MightyApk::ProtocolBuffers::ResponseWrapper, region]
      app = app_details(app_identifier)
      offer_type = app.offer[0].offerType
      version_code = app.details.appDetails.versionCode
      purchase_info, region = @api.purchase(app_identifier, offer_type, version_code)
      [MightyApk::ProtocolBuffers::ResponseWrapper
        .new.parse(purchase_info.body)
        .payload.buyResponse.purchaseStatusResponse.appDeliveryData, region]
    end

    def download!(app_identifier, destination)
      # Returns the region which this apk was downloaded in.
      purchase_info, region = purchase!(app_identifier)
      cookie = purchase_info.downloadAuthCookie[0]
      download_url = purchase_info.downloadUrl
      if region != nil
        Rails.logger.info "Downloading #{app_identifier} in #{region}"
      end
      @api.download(download_url, cookie, destination, region)
      region
    end
  end
end
