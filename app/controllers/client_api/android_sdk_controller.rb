class ClientApi::AndroidSdkController < ApplicationController

  before_action :limit_client_api_call, only: :show
  after_action :bill_api_request

  def show
    id = params.fetch(:id)
    ApiRequestAnalytics.new(request, @http_client_api_auth_token).log_request('android_sdk_show')
    render json: AndroidSdk.display_sdks.find(id).api_json
  end
end
