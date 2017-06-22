class ClientApi::AndroidAppController < ApplicationController

  before_action :authenticate_client_api_request, only: [:show, :filter]

  def show
    app_identifier = params.fetch(:app_identifier)
    render json: AndroidApp.find_by!(app_identifier: app_identifier).api_json
  end

  def filter
    filter = AppFilter.new(
      app_model: AndroidApp,
      es_client: AppsIndex::AndroidApp,
      query_params: params,
      platform: :android
    )
    filter.search!
    render json: filter.result
  end
end
