class ClientApi::IosAppController < ApplicationController

  before_action :limit_client_api_call, only: [:show, :filter]
  after_action :bill_api_request

  def show
    app_identifier = params.fetch(:app_identifier)
    ApiRequestAnalytics.new(request, @http_client_api_auth_token).log_request('ios_app_show')
    render json: IosApp.find_by!(app_identifier: app_identifier).api_json
  end

  def filter
    ApiRequestAnalytics.new(request, @http_client_api_auth_token).log_request('ios_app_filter')
    filter = AppFilter.new(
      app_model: IosApp,
      es_client: AppsIndex::IosApp,
      query_params: params,
      platform: :ios
    )
    filter.search!
    render json: filter.result
  end
end
