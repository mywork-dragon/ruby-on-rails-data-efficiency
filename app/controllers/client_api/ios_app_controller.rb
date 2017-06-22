class ClientApi::IosAppController < ApplicationController

  before_action :authenticate_client_api_request, only: [:show, :filter]

  def show
    app_identifier = params.fetch(:app_identifier)
    render json: IosApp.find_by!(app_identifier: app_identifier).api_json
  end

  def filter
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
