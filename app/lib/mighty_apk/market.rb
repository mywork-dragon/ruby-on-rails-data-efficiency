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
      app = app_details(app_identifier)
      offer_type = app.offer[0].offerType
      version_code = app.details.appDetails.versionCode
      purchase_info = @api.purchase(app_identifier, offer_type, version_code)
      MightyApk::ProtocolBuffers::ResponseWrapper
        .new.parse(purchase_info.body)
        .payload.buyResponse.purchaseStatusResponse.appDeliveryData
    end

    def download!(app_identifier, destination)
      purchase_info = purchase!(app_identifier)
      cookie = purchase_info.downloadAuthCookie[0]
      download_url = purchase_info.downloadUrl
      @api.download(download_url, cookie, destination)
    end
  end
end
